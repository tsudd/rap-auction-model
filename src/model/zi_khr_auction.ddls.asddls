@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Auction composite CDS entity view'
define root view entity zi_khr_auction
  as select from zb_khr_auction as Auction

  composition [0..*] of zi_khr_bid      as _Bid 
  composition [0..*] of zi_khr_itemm as _Item
  association [0..1] to /DMO/I_Customer as _Customer on $projection.HolderId = _Customer.CustomerID
  association [0..1] to I_Currency      as _Currency on $projection.CurrencyCode = _Currency.Currency
  association to zi_khr_maxbid as _MaxBid on $projection.AuctionUuid = _MaxBid.AuctionUuid
                                             and $projection.CurrencyCode = _MaxBid.CurrencyCode

{
  key AuctionUuid,
      AuctionId,
      HolderId,
      BeginDate,
      EndDate,
      ExparationDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BidIncrement,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      StartPrice,
      Description,
      CurrencyCode,
      OverallStatus,
      
      _MaxBid.HighestBidAmount as HighestBid,
       @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,

      _Customer,
      _Currency,
      _Bid,
      _Item,
      _MaxBid
}
