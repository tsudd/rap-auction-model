@AbapCatalog.sqlViewName: 'ZBKHRBID'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Bid base CDS view'
define view zb_khr_bid
  as select from zkhr_bid
{
  key bidding_uuid           as BiddingUuid,
      auction_uuid           as AuctionUuid,
      bidding_id             as BiddingId,
      owner_id               as OwnerId,
      bid_date               as BidDate,
      bid_amount             as BidAmount,
      currency_code          as CurrencyCode,
      cancel_bid_explanation as CancelBidExplanation,
      created_by             as CreatedBy,
      last_changed_by        as LastChangedBy,
      local_last_changed_at  as LocalLastChangedAt
}
