﻿using ErikEJ.Data.Entity.SqlServerCe.Metadata;
using Microsoft.Data.Entity.Metadata.Internal;
using Microsoft.Data.Entity.Metadata.ModelConventions;

namespace ErikEJ.Data.Entity.SqlServerCompact.MetaData.ModelConventions
{
    public class SqlServerCeValueGenerationStrategyConvention : IModelConvention
    {
        public virtual InternalModelBuilder Apply(InternalModelBuilder modelBuilder)
        {
            modelBuilder.Annotation(
                SqlServerCeAnnotationNames.Prefix + SqlServerCeAnnotationNames.ValueGeneration,
                SqlServerCeAnnotationNames.Strategy,
                ConfigurationSource.Convention);

            return modelBuilder;
        }
    }
}