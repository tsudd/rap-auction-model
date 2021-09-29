class lhc_Bid definition inheriting from cl_abap_behavior_handler.
  private section.

    methods calculateBiddingId for determine on save
      importing keys for Bid~calculateBiddingId.

    methods validateAmounts for validate on save
      importing keys for Bid~validateAmounts.

    methods validateOwner for validate on save
      importing keys for Bid~validateOwner.

endclass.

class lhc_Bid implementation.

  method calculateBiddingId.
    data max_id type zkhr_bid_id.
    data to_update type table for update zi_khr_auction\\Bid.

    read entities of zi_khr_auction in local mode
        entity Auction by \_Bid
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
                       %state_area        = 'Invalding_Owner' )
      to reported-bid.

      if bidding-OwnerId is initial or not line_exists( owners_db[ customer_id = bidding-OwnerId ] ).
        append value #( %tky = bidding-%tky ) to failed-bid.

        append value #( %tky        = bidding-%tky
                        %state_area = 'Invalding_Owner'
                        %msg        = new zcm_khr(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_khr=>owner_unknown
                                          customerid = bidding-OwnerId )
                        %element-OwnerId = if_abap_behv=>mk-on )
          to reported-bid.
      endif.
    endloop.
  endmethod.

endclass.
