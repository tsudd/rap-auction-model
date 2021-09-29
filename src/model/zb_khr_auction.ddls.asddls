@AbapCatalog.sqlViewName: 'ZBKHRAUCTION'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Auction base CDS view'
define view zb_khr_auction as select from zkhr_auction {
    key auction_uuid as AuctionUuid,
    auction_id as AuctionId,
    holder_id as HolderId,
    begin_date as BeginDate,
    end_date as EndDate,
    exparation_date as ExparationDate,
    bid_increment as BidIncrement,
    start_price as StartPrice,
    description as Description,
    currency_code as CurrencyCode,
    overall_status as OverallStatus,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt,
    local_last_changed_at as LocalLastChangedAt
}
