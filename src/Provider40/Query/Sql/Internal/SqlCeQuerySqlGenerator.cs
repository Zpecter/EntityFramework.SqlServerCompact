﻿using System;
using System.Linq;
using System.Linq.Expressions;
using JetBrains.Annotations;
using Microsoft.EntityFrameworkCore.Internal;
using Microsoft.EntityFrameworkCore.Query.Expressions;
using Microsoft.EntityFrameworkCore.Query.Expressions.Internal;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.EntityFrameworkCore.Utilities;
using Remotion.Linq.Clauses;

namespace Microsoft.EntityFrameworkCore.Query.Sql.Internal
{
    public class SqlCeQuerySqlGenerator : DefaultQuerySqlGenerator, ISqlCeExpressionVisitor
    {
        public SqlCeQuerySqlGenerator(
            [NotNull] IRelationalCommandBuilderFactory commandBuilderFactory,
            [NotNull] ISqlGenerationHelper sqlGenerationHelper,
            [NotNull] IParameterNameGeneratorFactory parameterNameGeneratorFactory,
            [NotNull] IRelationalTypeMapper relationalTypeMapper,
            [NotNull] SelectExpression selectExpression)
            : base(commandBuilderFactory, sqlGenerationHelper, parameterNameGeneratorFactory, relationalTypeMapper, selectExpression)
        {
        }

        public override Expression VisitLateralJoin(LateralJoinExpression lateralJoinExpression)
        {
            Check.NotNull(lateralJoinExpression, nameof(lateralJoinExpression));

            Sql.Append("CROSS APPLY ");

            Visit(lateralJoinExpression.TableExpression);

            return lateralJoinExpression;
        }

        public override Expression VisitSqlFunction(SqlFunctionExpression sqlFunctionExpression)
        {
            if (sqlFunctionExpression.FunctionName.StartsWith("@@", StringComparison.Ordinal))
            {
                Sql.Append(sqlFunctionExpression.FunctionName);

                return sqlFunctionExpression;
            }

            if ((sqlFunctionExpression.FunctionName == "COUNT")
                && (sqlFunctionExpression.Type == typeof(long)))
            {
                Sql.Append("CAST(COUNT(*) AS bigint)");

                return sqlFunctionExpression;
            }

            return base.VisitSqlFunction(sqlFunctionExpression);
        }

        public virtual Expression VisitDatePartExpression(DatePartExpression datePartExpression)
        {
            Check.NotNull(datePartExpression, nameof(datePartExpression));

            Sql.Append("DATEPART(")
                .Append(datePartExpression.DatePart)
                .Append(", ");
            Visit(datePartExpression.Argument);
            Sql.Append(")");
            return datePartExpression;
        }

        protected override void GenerateLimitOffset(SelectExpression selectExpression)
        {
#if SQLCE35
            if (selectExpression.Offset != null)
            {
                throw new NotSupportedException("SKIP clause is not supported by SQL Server Compact 3.5");
            }
#endif
            if ((selectExpression.Offset != null)
                && !selectExpression.OrderBy.Any())
            {
                Sql.AppendLine().Append("ORDER BY GETDATE()");
            }

            base.GenerateLimitOffset(selectExpression);
        }

        protected override void GenerateOrdering(Ordering ordering)
        {
            if (ordering.Expression is ParameterExpression
                || ordering.Expression is ConstantExpression)
            {
                Sql.Append("GETDATE()");
            }
            else
            {
                base.GenerateOrdering(ordering);
            }
        }

        protected override Expression VisitBinary(BinaryExpression expression)
        {
            if ((expression.NodeType == ExpressionType.Equal)
                || (expression.NodeType == ExpressionType.NotEqual))
            {
                var left = expression.Left.RemoveConvert();
                var right = expression.Right.RemoveConvert();
                Expression replacedExpression = null;
                var leftSelect = left as SelectExpression;
                var rightSelect = right as SelectExpression;
                if ((leftSelect != null) && (rightSelect == null))
                {
                    replacedExpression = new InExpression(
                        right as AliasExpression ?? new AliasExpression(right), leftSelect);
                }

                if ((rightSelect != null) && (leftSelect == null))
                {
                    replacedExpression = new InExpression(
                        left as AliasExpression ?? new AliasExpression(left), rightSelect);
                }

                if (replacedExpression != null)
                {
                    replacedExpression = expression.NodeType == ExpressionType.Equal
                        ? replacedExpression
                        : Expression.Not(replacedExpression);
                    return Visit(replacedExpression);
                }
            }
            return base.VisitBinary(expression);
        }
    }
}
