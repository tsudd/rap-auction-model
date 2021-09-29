@EndUserText.label: 'Bid consumption view'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity zc_khr_bid
  as projection on zi_khr_bid
{
  key BiddingUuid,
      AuctionUuid,
      @Search.defaultSearchElement: true
      BiddingId,
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Customer', element: 'CustomerID'  } }]
      @ObjectModel.text.element: ['OwnerName']
      @Search.defaultSearchElement: true
      OwnerId,
      _Customer.LastName as OwnerName,
      BidDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BidAmount,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
      CurrencyCode,
      CancelBidExplanation,
      LocalLastChangedAt,
      /* Associations */
      _Auction : redirected to parent zc_khr_auction,
      _Currency,
      _Customer
}
