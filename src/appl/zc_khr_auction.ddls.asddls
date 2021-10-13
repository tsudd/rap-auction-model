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
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer', element: 'CustomerId'} }]
      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      HolderId,
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer', element: 'LastName'} }]
      @Search.fuzzinessThreshold: 0.8
      _Customer.LastName as CustomerName,
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
      OverallStatus,
      LocalLastChangedAt,
      /* Associations */
      _Bid : redirected to composition child zc_khr_bid,
      _Item : redirected to composition child zc_khr_item,
      _Currency,
      _Customer
}
