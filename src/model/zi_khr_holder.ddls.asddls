@AbapCatalog.sqlViewName: 'ZIKHRHOLDER'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Holder interface view'
@Search.searchable: true

@ObjectModel: {
    representativeKey: 'HolderId'
}
define view zi_khr_holder
  as select from /dmo/customer as Customer
  association [0..1] to I_Country as _Country on $projection.CountryCode = _Country.Country
{
      @ObjectModel.text.element: ['FullName']
  key Customer.customer_id                                          as HolderId,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.name.givenName: true
      Customer.first_name                                           as FirstName,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      @Semantics.name.fullName: true
      concat_with_space(Customer.first_name, Customer.last_name, 1) as FullName,
      @Semantics.name.familyName: true
      Customer.last_name                                            as LastName,
      @Semantics.name.prefix: true
      Customer.title                                                as Title,
      @Semantics.address.street: true
      Customer.street                                               as Street,
      @Semantics.text: true
      @Semantics.address.type: [#HOME]
      concat_with_space(Customer.city, Customer.postal_code, 1) as Address,
      @Semantics.address.zipCode: true
      @Semantics.address.type: [#WORK]
      Customer.postal_code                                          as PostalCode,
      @Semantics.address.city: true
      @Semantics.text: true
      Customer.city                                                 as City,
      @Consumption.valueHelpDefinition: [{entity: { name: 'I_Country', element: 'Country' } }]
      @Semantics.address.country: true
      Customer.country_code                                         as CountryCode,
      @Semantics.telephone.type: [#WORK, #PREF]
      Customer.phone_number                                         as PhoneNumber,
      @Semantics.eMail.address
      @Semantics:{ eMail.type:  [ #WORK ] }
      Customer.email_address                                        as EmailAddress,
      /* Associations */
      _Country
}
