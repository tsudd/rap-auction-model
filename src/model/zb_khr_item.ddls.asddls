@AbapCatalog.sqlViewName: 'ZBKHRITEM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item base CDS view'
define view zb_khr_item
  as select from zkhr_item
{
  key item_uuid             as ItemUuid,
      auction_uuid          as AuctionUuid,
      owner_id              as OwnerId,
      item_id               as ItemId,
      item_name             as ItemName,
      item_description      as ItemDescription,
      image_url             as ImageUrl,
      category              as Category,
      createdby            as CreatedBy,
      lastchangedby       as LastChangedBy,
      local_last_changed_at as LocalLastChangedAt
}
