@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Item composite CDS entity view'
define view entity zi_khr_itemm
  as select from zb_khr_item
  
  association to parent zi_khr_auction as _Auction on $projection.AuctionUuid = _Auction.AuctionUuid
  association [0..1] to /DMO/I_Customer     as _Customer on $projection.OwnerId = _Customer.CustomerID
{
  key ItemUuid,
      AuctionUuid,
      OwnerId,
      ItemId,
      ItemName,
      ItemDescription,
      ImageUrl,
      Category,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      
      _Auction,
      _Customer
}
