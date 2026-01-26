// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_settings_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFinanceSettingsModelCollection on Isar {
  IsarCollection<FinanceSettingsModel> get financeSettingsModels =>
      this.collection();
}

const FinanceSettingsModelSchema = CollectionSchema(
  name: r'FinanceSettingsModel',
  id: 3613007757471673367,
  properties: {
    r'budget': PropertySchema(
      id: 0,
      name: r'budget',
      type: IsarType.double,
    ),
    r'expenseCategories': PropertySchema(
      id: 1,
      name: r'expenseCategories',
      type: IsarType.objectList,
      target: r'FinanceCategory',
    ),
    r'incomeCategories': PropertySchema(
      id: 2,
      name: r'incomeCategories',
      type: IsarType.objectList,
      target: r'FinanceCategory',
    )
  },
  estimateSize: _financeSettingsModelEstimateSize,
  serialize: _financeSettingsModelSerialize,
  deserialize: _financeSettingsModelDeserialize,
  deserializeProp: _financeSettingsModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'FinanceCategory': FinanceCategorySchema},
  getId: _financeSettingsModelGetId,
  getLinks: _financeSettingsModelGetLinks,
  attach: _financeSettingsModelAttach,
  version: '3.1.0+1',
);

int _financeSettingsModelEstimateSize(
  FinanceSettingsModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.expenseCategories;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[FinanceCategory]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              FinanceCategorySchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  {
    final list = object.incomeCategories;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[FinanceCategory]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              FinanceCategorySchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  return bytesCount;
}

void _financeSettingsModelSerialize(
  FinanceSettingsModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.budget);
  writer.writeObjectList<FinanceCategory>(
    offsets[1],
    allOffsets,
    FinanceCategorySchema.serialize,
    object.expenseCategories,
  );
  writer.writeObjectList<FinanceCategory>(
    offsets[2],
    allOffsets,
    FinanceCategorySchema.serialize,
    object.incomeCategories,
  );
}

FinanceSettingsModel _financeSettingsModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FinanceSettingsModel();
  object.budget = reader.readDouble(offsets[0]);
  object.expenseCategories = reader.readObjectList<FinanceCategory>(
    offsets[1],
    FinanceCategorySchema.deserialize,
    allOffsets,
    FinanceCategory(),
  );
  object.id = id;
  object.incomeCategories = reader.readObjectList<FinanceCategory>(
    offsets[2],
    FinanceCategorySchema.deserialize,
    allOffsets,
    FinanceCategory(),
  );
  return object;
}

P _financeSettingsModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readObjectList<FinanceCategory>(
        offset,
        FinanceCategorySchema.deserialize,
        allOffsets,
        FinanceCategory(),
      )) as P;
    case 2:
      return (reader.readObjectList<FinanceCategory>(
        offset,
        FinanceCategorySchema.deserialize,
        allOffsets,
        FinanceCategory(),
      )) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _financeSettingsModelGetId(FinanceSettingsModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _financeSettingsModelGetLinks(
    FinanceSettingsModel object) {
  return [];
}

void _financeSettingsModelAttach(
    IsarCollection<dynamic> col, Id id, FinanceSettingsModel object) {
  object.id = id;
}

extension FinanceSettingsModelQueryWhereSort
    on QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QWhere> {
  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FinanceSettingsModelQueryWhere
    on QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QWhereClause> {
  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FinanceSettingsModelQueryFilter on QueryBuilder<FinanceSettingsModel,
    FinanceSettingsModel, QFilterCondition> {
  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> budgetEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'budget',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> budgetGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'budget',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> budgetLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'budget',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> budgetBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'budget',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> expenseCategoriesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expenseCategories',
      ));
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> expenseCategoriesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expenseCategories',
      ));
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> expenseCategoriesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'expenseCategories',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> expenseCategoriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'expenseCategories',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> expenseCategoriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'expenseCategories',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> expenseCategoriesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'expenseCategories',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> expenseCategoriesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'expenseCategories',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> expenseCategoriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'expenseCategories',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> incomeCategoriesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'incomeCategories',
      ));
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> incomeCategoriesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'incomeCategories',
      ));
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> incomeCategoriesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'incomeCategories',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> incomeCategoriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'incomeCategories',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> incomeCategoriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'incomeCategories',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> incomeCategoriesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'incomeCategories',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> incomeCategoriesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'incomeCategories',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
      QAfterFilterCondition> incomeCategoriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'incomeCategories',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension FinanceSettingsModelQueryObject on QueryBuilder<FinanceSettingsModel,
    FinanceSettingsModel, QFilterCondition> {
  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
          QAfterFilterCondition>
      expenseCategoriesElement(FilterQuery<FinanceCategory> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'expenseCategories');
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel,
          QAfterFilterCondition>
      incomeCategoriesElement(FilterQuery<FinanceCategory> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'incomeCategories');
    });
  }
}

extension FinanceSettingsModelQueryLinks on QueryBuilder<FinanceSettingsModel,
    FinanceSettingsModel, QFilterCondition> {}

extension FinanceSettingsModelQuerySortBy
    on QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QSortBy> {
  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QAfterSortBy>
      sortByBudget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budget', Sort.asc);
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QAfterSortBy>
      sortByBudgetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budget', Sort.desc);
    });
  }
}

extension FinanceSettingsModelQuerySortThenBy
    on QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QSortThenBy> {
  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QAfterSortBy>
      thenByBudget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budget', Sort.asc);
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QAfterSortBy>
      thenByBudgetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budget', Sort.desc);
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension FinanceSettingsModelQueryWhereDistinct
    on QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QDistinct> {
  QueryBuilder<FinanceSettingsModel, FinanceSettingsModel, QDistinct>
      distinctByBudget() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'budget');
    });
  }
}

extension FinanceSettingsModelQueryProperty on QueryBuilder<
    FinanceSettingsModel, FinanceSettingsModel, QQueryProperty> {
  QueryBuilder<FinanceSettingsModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FinanceSettingsModel, double, QQueryOperations>
      budgetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'budget');
    });
  }

  QueryBuilder<FinanceSettingsModel, List<FinanceCategory>?, QQueryOperations>
      expenseCategoriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expenseCategories');
    });
  }

  QueryBuilder<FinanceSettingsModel, List<FinanceCategory>?, QQueryOperations>
      incomeCategoriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'incomeCategories');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const FinanceCategorySchema = Schema(
  name: r'FinanceCategory',
  id: 4166339522725285410,
  properties: {
    r'color': PropertySchema(
      id: 0,
      name: r'color',
      type: IsarType.string,
    ),
    r'icon': PropertySchema(
      id: 1,
      name: r'icon',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 2,
      name: r'id',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _financeCategoryEstimateSize,
  serialize: _financeCategorySerialize,
  deserialize: _financeCategoryDeserialize,
  deserializeProp: _financeCategoryDeserializeProp,
);

int _financeCategoryEstimateSize(
  FinanceCategory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.color;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.id;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _financeCategorySerialize(
  FinanceCategory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.color);
  writer.writeLong(offsets[1], object.icon);
  writer.writeString(offsets[2], object.id);
  writer.writeString(offsets[3], object.name);
}

FinanceCategory _financeCategoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FinanceCategory();
  object.color = reader.readStringOrNull(offsets[0]);
  object.icon = reader.readLongOrNull(offsets[1]);
  object.id = reader.readStringOrNull(offsets[2]);
  object.name = reader.readStringOrNull(offsets[3]);
  return object;
}

P _financeCategoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension FinanceCategoryQueryFilter
    on QueryBuilder<FinanceCategory, FinanceCategory, QFilterCondition> {
  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      colorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'color',
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      colorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'color',
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      colorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      colorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      colorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      colorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'color',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      colorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      colorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      colorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      colorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'color',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      colorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'color',
        value: '',
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      colorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'color',
        value: '',
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      iconIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'icon',
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      iconIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'icon',
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      iconEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'icon',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      iconGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'icon',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      iconLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'icon',
        value: value,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      iconBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'icon',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      idEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      idGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      idLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      idBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FinanceCategory, FinanceCategory, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension FinanceCategoryQueryObject
    on QueryBuilder<FinanceCategory, FinanceCategory, QFilterCondition> {}
