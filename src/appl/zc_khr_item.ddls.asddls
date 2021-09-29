@EndUserText.label: 'Item consumption CDS entity view'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity zc_khr_item
  as projection on zi_khr_itemm
{
  key ItemUuid,
      AuctionUuid,
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Customer', element: 'CustomerID'  } }]
      @ObjectModel.text.element: ['OwnerName']
      @Search.defaultSearchElement: true
      OwnerId,
      _Customer.LastName as OwnerName,
      @Search.defaultSearchElement: true
      ItemId,
      ItemName,
      ItemDescription,
      ImageUrl,
      Category,
      LocalLastChangedAt,
      /* Associations */
      _Auction : redirected to parent zc_khr_auction,
      _Customer
}
