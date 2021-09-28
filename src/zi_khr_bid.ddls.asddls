@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Bid composite view'

define view entity zi_khr_bid
  as select from zb_khr_bid
  association [0..1] to I_Currency          as _Currency on $projection.CurrencyCode = _Currency.Currency
  association [0..1] to /DMO/I_Customer     as _Customer on $projection.OwnerId = _Customer.CustomerID
  association to parent zi_khr_auction as _Auction on $projection.AuctionUuid = _Auction.AuctionUuid
{
    key BiddingUuid,
    AuctionUuid,
    BiddingId,
    OwnerId,
    BidDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BidAmount,
    CurrencyCode,
    CancelBidExplanation,
    @Semantics.user.createdBy: true
    CreatedBy,
    @Semantics.user.lastChangedBy: true
    LastChangedBy,
     @Semantics.systemDateTime.localInstanceLastChangedAt: true
    LocalLastChangedAt,
    
    _Currency,
    _Customer,
    _Auction
  }
