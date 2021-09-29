@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'View with calculated max bid'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_khr_maxbid as select from zi_khr_bid {
    key AuctionUuid,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    max( BidAmount ) as HighestBidAmount,
    CurrencyCode
}
group by AuctionUuid, CurrencyCode
