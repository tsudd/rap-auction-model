    @EndUserText.label: 'Auction consumption CDS view'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity zc_khr_auction
  as projection on zi_khr_auction as Auction
{
  key AuctionUuid,
  @Search.defaultSearchElement: true
      AuctionId,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'zi_khr_holder', element: 'HolderId'} }]
      @ObjectModel.text.element: ['HolderName']
      @Search.defaultSearchElement: true
      HolderId,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'zi_khr_holder', element: 'LastName'} }]
      @Search.fuzzinessThreshold: 0.8
      _Holder.LastName as HolderName,
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      BeginDate,
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      EndDate,
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      ExparationDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BidIncrement,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      StartPrice,
      HighestBid,
      @Search.fuzzinessThreshold: 0.2
      Description,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency'} }]
      CurrencyCode,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_KHR_STATUS', element: 'Description'} }]
//      @Consumption.valueHelpDefinition.presentationVariantQualifier: ''
//      @Consumption.valueHelp: 'ZI_KHR_SATUS'
      OverallStatus,
      LocalLastChangedAt,
      /* Associations */
      _Bid : redirected to composition child zc_khr_bid,
      _Item : redirected to composition child zc_khr_item,
      _Currency,
      _Holder
}
