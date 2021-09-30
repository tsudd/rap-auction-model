class lhc_Bid definition inheriting from cl_abap_behavior_handler.
  private section.

    methods calculateBiddingId for determine on save
      importing keys for Bid~calculateBiddingId.

    methods validateAmounts for validate on save
      importing keys for Bid~validateAmounts.

    methods validateOwner for validate on save
      importing keys for Bid~validateOwner.
    methods get_instance_features for instance features
      importing keys request requested_features for Bid result result.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for Bid result result.

    methods acceptBid for modify
      importing keys for action Bid~acceptBid.

    methods rejectBid for modify
      importing keys for action Bid~rejectBid.

    methods setCurrencyCode for modify
      importing keys for action Bid~setCurrencyCode.

endclass.

class lhc_Bid implementation.

  method calculateBiddingId.
    data max_id type zkhr_bid_id.
    data to_update type table for update zi_khr_auction\\Bid.

    read entities of zi_khr_auction in local mode
        entity Bid by \_Auction
            fields ( AuctionUuid )
        with corresponding #( keys )
        result data(auctions).

    loop at auctions into data(auction).
      read entities of zi_khr_auction in local mode
          entity Auction by \_Bid
      fields ( BiddingId )
      with value #( ( %tky = auction-%tky ) )
      result data(biddings).

      max_id = '0000'.
      loop at biddings into data(bid).
        if bid-BiddingId > max_id.
          max_id = bid-BiddingId.
        endif.
      endloop.

      loop at biddings into bid where BiddingId is initial.
        max_id += 10.
        insert value #( %tky = bid-%tky
                        %is_draft = if_abap_behv=>mk-off
                        BiddingUuid = bid-BiddingUuid
                        BiddingId = max_id ) into table to_update.
      endloop.
    endloop.

    modify entities of zi_khr_auction in local mode
        entity Bid
            update fields ( BiddingId ) with to_update
        reported data(update_reported).

    reported = corresponding #( deep update_reported ).
  endmethod.

  method validateAmounts.
    read entities of zi_khr_auction in local mode
        entity Bid
        fields ( BiddingId BidAmount AuctionUuid  ) with corresponding #( keys )
        result data(biddings).

    data auctions type sorted table of zkhr_auction with unique key auction_uuid.

    auctions = corresponding #( biddings discarding duplicates mapping auction_uuid = AuctionUuid except * ).

    if auctions is not initial.
      read entities of zi_khr_auction in local mode
          entity Bid by \_Auction
          fields ( BidIncrement StartPrice AuctionUuid HighestBid ) with corresponding #( auctions )
      result data(auctions_db).
    endif.

*    loop at biddings into data(bid).
*      append value #( %tky = bid-%tky
*                      %state_area = 'VALIDATE_AMOUNTS' )
*      to reported-bid.
*
*      if bid-BidAmount < 0.
*        append value #( %tky = bid-%tky ) to failed-bid.
*        append value #( %tky = bid-%tky
*                        %state_area = 'VALIDATE_AMOUNTS'
*                        %msg = new zcm_khr( severity = if_abap_behv_message=>severity-error
*                                            textid = zcm_khr=>negative_bid )
*                        %element-BidAmount = if_abap_behv=>mk-on )
*        to reported-bid.
*      else.
*        data(linked_auction) = auctions_db[ AuctionUuid = bid-AuctionUuid ].
*        if linked_auction-HighestBid = 0 and linked_auction-StartPrice > bid-BidAmount.
*          append value #( %tky = bid-%tky ) to failed-bid.
*          append value #( %tky = bid-%tky
*                          %state_area = 'VALIDATE_AMOUNTS'
*                          %msg = new zcm_khr( severity = if_abap_behv_message=>severity-error
*                                              textid = zcm_khr=>low_bid_amount
*                                              startprice = linked_auction-StartPrice )
*                          %element-BidAmount = if_abap_behv=>mk-on )
*          to reported-bid.
*        elseif linked_auction-HighestBid > 0 and
*               linked_auction-HighestBid + linked_auction-BidIncrement > bid-BidAmount.
*          append value #( %tky = bid-%tky ) to failed-bid.
*          append value #( %tky = bid-%tky
*                          %state_area = 'VALIDATE_AMOUNTS'
*                          %msg = new zcm_khr( severity = if_abap_behv_message=>severity-error
*                                              textid = zcm_khr=>low_bid_amount
*                                              startprice = linked_auction-StartPrice )
*                          %element-BidAmount = if_abap_behv=>mk-on )
*          to reported-bid.
*        endif.
*      endif.
*    endloop.
  endmethod.

  method validateOwner.
    read entities of zi_khr_auction in local mode
      entity Auction by \_Bid
        fields ( OwnerId ) with corresponding #( keys )
      result data(biddings).

    data owners type sorted table of /dmo/customer with unique key customer_id.

    owners = corresponding #( biddings discarding duplicates mapping customer_id = OwnerId except * ).

    if owners is not initial.
      select from /dmo/customer fields customer_id
          for all entries in @owners
          where customer_id = @owners-customer_id
          into table @data(owners_db).
    endif.

    loop at biddings into data(bidding).
      append value #(  %tky               = bidding-%tky
                       %state_area        = 'Invalid_Owner' )
      to reported-bid.

      if bidding-OwnerId is initial or not line_exists( owners_db[ customer_id = bidding-OwnerId ] ).
        append value #( %tky = bidding-%tky ) to failed-bid.

        append value #( %tky        = bidding-%tky
                        %state_area = 'Invalid_Owner'
                        %msg        = new zcm_khr(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_khr=>owner_unknown
                                          customerid = bidding-OwnerId )
                        %element-OwnerId = if_abap_behv=>mk-on )
          to reported-bid.
      endif.
    endloop.
  endmethod.

  method get_instance_features.
  endmethod.

  method get_instance_authorizations.
  endmethod.

  method acceptBid.
  endmethod.

  method rejectBid.
  endmethod.

  method setCurrencyCode.
    read entities of zi_khr_auction in local mode
        entity Bid
            fields ( CurrencyCode AuctionUuid ) with corresponding #( keys )
        result data(biddings).

    data auctions type sorted table of zkhr_auction with unique key auction_uuid.

    auctions = corresponding #( biddings discarding duplicates mapping auction_uuid = AuctionUuid except * ).

    if auctions is not initial.
      select from zkhr_auction fields currency_code, auction_uuid
        for all entries in @auctions
        where auction_uuid = @auctions-auction_uuid
        into table @data(auctions_db).
    endif.

    modify entities of zi_khr_auction in local mode
    entity Bid
        update
            set fields with value #( for bid in biddings
                          ( %is_draft = if_abap_behv=>mk-off
                            BiddingUuid = bid-BiddingUuid
                            CurrencyCode = auctions_db[ auction_uuid = bid-AuctionUuid ]-currency_code ) )
    reported data(update_reported)
    failed data(blyat).


    reported = corresponding #( deep update_reported ).
  endmethod.

endclass.
