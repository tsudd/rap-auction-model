class test_auction_beh definition deferred for testing.

class lhc_Auction definition inheriting from cl_abap_behavior_handler friends test_auction_beh.
  public section.
    constants:
      begin of auction_status,
        prepairing type c length 1 value 'P',
        reviewing  type c length 1 value 'R',
        bargaining type c length 1 value 'B',
        sold       type c length 1 value 'S',
        completed  type c length 1 value 'C',
        ready      type c length 1 value 'D',
        canceled   type c length 1 value 'X',
      end of auction_status.

    constants:
                 sum_bid_id type c length 4 value '0000'.
  private section.

    methods get_instance_features for instance features
      importing keys request requested_features for Auction result result.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for Auction result result.

    methods is_update_granted importing has_before_image      type abap_bool
                                        overall_status        type zkhr_auction_status
                              returning value(update_granted) type abap_bool.

    methods is_delete_granted importing has_before_image      type abap_bool
                                        overall_status        type zkhr_auction_status
                              returning value(delete_granted) type abap_bool.

    methods is_create_granted returning value(create_granted) type abap_bool.

    methods cancelAuction for modify
      importing keys for action Auction~cancelAuction result result.

    methods startBargaining for modify
      importing keys for action Auction~startBargaining result result.

    methods calculateAuctionId for determine on save
      importing keys for Auction~calculateAuctionId.

    methods setAuctionStatus for determine on save
      importing keys for Auction~setAuctionStatus.

    methods validateDates for validate on save
      importing keys for Auction~validateDates.

    methods validateHolder for validate on save
      importing keys for Auction~validateHolder.

    methods validatePrices for validate on save
      importing keys for Auction~validatePrices.

endclass.

class lhc_Auction implementation.

  method get_instance_features.
  endmethod.

  method get_instance_authorizations.
    data has_before_image type abap_bool.
    data is_update_requested type abap_bool.
    data is_delete_requested type abap_bool.
    data update_granted type abap_bool.
    data delete_granted type abap_bool.

    data failed_auction like line of failed-auction.

    read entities of zi_khr_auction in local mode
        entity Auction
            fields ( OverallStatus ) with corresponding #( keys )
        result data(auctions)
        failed failed.

    check auctions is not initial.

    select from zkhr_auction
        fields auction_uuid, overall_status
        for all entries in @auctions
        where auction_uuid eq @auctions-AuctionUuid
        order by primary key
        into table @data(auctions_before_image).

    is_update_requested = cond #( when requested_authorizations-%update = if_abap_behv=>mk-on or
                                       requested_authorizations-%action-startBargaining = if_abap_behv=>mk-on or
                                       requested_authorizations-%action-cancelAuction = if_abap_behv=>mk-on or
                                       requested_authorizations-%action-Prepare = if_abap_behv=>mk-on or
                                       requested_authorizations-%action-Edit = if_abap_behv=>mk-on or
                                       requested_authorizations-%assoc-_Bid = if_abap_behv=>mk-on
                                  then abap_true
                                  else abap_false ).

    is_delete_requested = cond #( when requested_authorizations-%delete = if_abap_behv=>mk-on
                                  then abap_true
                                  else abap_false ).

    loop at auctions into data(auction).
      update_granted = delete_granted = abap_false.

      read table auctions_before_image into data(auction_before_image)
          with key auction_uuid = auction-AuctionUuid binary search.
      has_before_image = cond #( when sy-subrc = 0 then abap_true else abap_false ).

      if is_update_requested = abap_true.
        if has_before_image = abap_true.
          update_granted = is_update_granted( has_before_image = has_before_image
                                              overall_status = auction_before_image-overall_status ).
          if update_granted = abap_false.
            append value #( %tky = auction-%tky
                            %msg = new zcm_khr( severity = if_abap_behv_message=>severity-error
                                                textid = zcm_khr=>unautharized ) )
            to reported-auction.
          endif.
        else.
          update_granted = is_create_granted(  ).
          if update_granted = abap_false.
            append value #( %tky = auction-%tky
                            %msg = new zcm_khr( severity = if_abap_behv_message=>severity-error
                                                textid = zcm_khr=>unautharized ) )
            to reported-auction.
          endif.
        endif.
      endif.

      if is_delete_requested = abap_true.
        delete_granted = is_delete_granted( has_before_image = has_before_image
                                            overall_status = auction_before_image-overall_status ).
        if delete_granted = abap_false.
          append value #( %tky = auction-%tky
                          %msg = new zcm_khr( severity = if_abap_behv_message=>severity-error
                                              textid = zcm_khr=>unautharized ) )
          to reported-auction.
        endif.
      endif.

      append value #( %tky = auction-%tky

                      %update = cond #( when update_granted = abap_true
                                        then if_abap_behv=>auth-allowed
                                        else if_abap_behv=>auth-unauthorized )
                      %action-cancelAuction = cond #( when update_granted = abap_true
                                        then if_abap_behv=>auth-allowed
                                        else if_abap_behv=>auth-unauthorized )
                      %action-startBargaining = cond #( when update_granted = abap_true
                                        then if_abap_behv=>auth-allowed
                                        else if_abap_behv=>auth-unauthorized )
                      %action-Prepare = cond #( when update_granted = abap_true
                                                then if_abap_behv=>auth-allowed
                                                else if_abap_behv=>auth-unauthorized )
                      %action-Edit = cond #( when update_granted = abap_true
                                                then if_abap_behv=>auth-allowed
                                                else if_abap_behv=>auth-unauthorized )
                      %assoc-_Bid = cond #( when update_granted = abap_true
                                        then if_abap_behv=>auth-allowed
                                        else if_abap_behv=>auth-unauthorized )
                      %delete = cond #( when update_granted = abap_true
                                        then if_abap_behv=>auth-allowed
                                        else if_abap_behv=>auth-unauthorized ) )
      to result.
    endloop.
  endmethod.

  method cancelAuction.
    modify entities of zi_khr_auction in local mode
        entity Auction
            update
                fields ( OverallStatus )
                with value #( for key in keys
                                ( %tky = key-%tky
                                  OverallStatus = auction_status-canceled ) )
            failed failed
            reported reported.
    read entities of zi_khr_auction in local mode
        entity Auction
            all fields with corresponding #( keys )
            result data(auctions).
    result = value #( for auction in auctions
                        ( %tky = auction-%tky
                          %param = auction ) ).
*    result = change_status( keys = keys status = auction_status-canceled ).
  endmethod.


  method startBargaining.
    read entities of zi_khr_auction in local mode
        entity Auction
            fields ( OverallStatus )
            with corresponding #( keys )
            result data(read_auctions_result).

    data keys_to_update like keys.
    data keys_to_error like keys.
    loop at read_auctions_result into data(auction).
      if auction-OverallStatus = auction_status-ready.
        insert corresponding #( auction ) into table keys_to_update.
      else.
        insert corresponding #( auction ) into table keys_to_error.
      endif.
    endloop.

    modify entities of zi_khr_auction in local mode
          entity Auction
              update
                  fields ( OverallStatus )
                  with value #( for key in keys_to_update
                                  ( %tky = key-%tky
                                    OverallStatus = auction_status-bargaining ) )
              failed failed
              reported reported.

    loop at keys_to_error into data(k).
      " couldn't use insert because of implicit index
      append value #( %tky = k-%tky ) to failed-auction.

      append value #( %tky = k-%tky
                      %state_area = 'AUCTION_BARGAINING'
                      %msg = new zcm_khr( severity = if_abap_behv_message=>severity-error
                                          textid = cond #( when read_auctions_result[
                                                                AuctionUuid = k-AuctionUuid ]-OverallStatus  = 'C'
                                                           then zcm_khr=>canceled_auction
                                                           else zcm_khr=>unready_auction )
                                          auctionid = auction-AuctionId ) )
      to reported-auction.
    endloop.

    read entities of zi_khr_auction in local mode
        entity Auction
            all fields with corresponding #( keys_to_update )
            result data(updated_auctions).
    result = value #( for auc in updated_auctions
                        ( %tky = auc-%tky
                          %param = auc ) ).
  endmethod.

  method calculateAuctionId.
    read entities of zi_khr_auction in local mode
      entity Auction
        fields ( AuctionId ) with corresponding #( keys )
      result data(auctions).

    delete auctions where AuctionId is not initial.

    check auctions is not initial.

    select single
        from  zi_khr_auction
        fields max( AuctionId ) as AuctionID "wrong, but what about ETag and draft concept?
        into @data(max_auctionid).

    modify entities of zi_khr_auction in local mode
    entity Auction
      update
        from value #( for auction in auctions index into i (
          %tky              = auction-%tky
          AuctionId        = max_auctionid + i
          %control-AuctionId = if_abap_behv=>mk-on ) )
    reported data(update_reported).

    reported = corresponding #( deep update_reported ).
  endmethod.

  method validateDates.
    read entities of zi_khr_auction in local mode
      entity Auction
        fields ( AuctionId BeginDate EndDate ExparationDate ) with corresponding #( keys )
      result data(auctions).

    loop at auctions into data(auction).
      if auction-ExparationDate < auction-BeginDate.
        append value #( %tky = auction-%tky ) to failed-auction.
        append value #( %tky               = auction-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = new zcm_khr(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_khr=>date_interval
                                                 begindate = auction-BeginDate
                                                 expdate   = auction-ExparationDate
                                                 auctionid  = auction-AuctionId )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %element-ExparationDate   = if_abap_behv=>mk-on ) to reported-auction.
      else.
        append value #(  %tky        = auction-%tky
                       %state_area = 'VALIDATE_DATES' )
        to reported-auction.
      endif.
    endloop.
  endmethod.

  method validateHolder.
    read entities of zi_khr_auction in local mode
      entity Auction
        fields ( HolderId ) with corresponding #( keys )
      result data(auctions).

    data holders type sorted table of /dmo/customer with unique key customer_id.

    holders = corresponding #( auctions discarding duplicates mapping customer_id = HolderId except * ).

    if holders is not initial.
      select from /dmo/customer fields customer_id
          for all entries in @holders
          where customer_id = @holders-customer_id
          into table @data(holders_db).
    endif.

    loop at auctions into data(auction).
      if auction-HolderId is initial or not line_exists( holders_db[ customer_id = auction-HolderId ] ).
        append value #( %tky = auction-%tky ) to failed-auction.

        append value #( %tky        = auction-%tky
                        %state_area = 'VALIDATE_HOLDER'
                        %msg        = new zcm_khr(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_khr=>holder_unknown
                                          customerid = auction-HolderId )
                        %element-HolderId = if_abap_behv=>mk-on )
          to reported-auction.
      else.
        append value #(  %tky               = auction-%tky
                       %state_area        = 'VALIDATE_HOLDER' )
        to reported-auction.
      endif.
    endloop.
  endmethod.

  method validatePrices.
    read entities of zi_khr_auction in local mode
      entity Auction
        fields ( AuctionId StartPrice BidIncrement ) with corresponding #( keys )
      result data(auctions).

    loop at auctions into data(auction).
      append value #(  %tky        = auction-%tky
                       %state_area = 'VALIDATE_PRICES' )
        to reported-auction.

      if auction-BidIncrement < 0.
        append value #( %tky = auction-%tky ) to failed-auction.
        append value #( %tky               = auction-%tky
                        %state_area        = 'VALIDATE_PRICES'
                        %msg               = new zcm_khr(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_khr=>negative_price )
                        %element-BidIncrement = if_abap_behv=>mk-on ) to reported-auction.
      elseif auction-StartPrice < 0.
        append value #( %tky = auction-%tky ) to failed-auction.
        append value #( %tky               = auction-%tky
                        %state_area        = 'VALIDATE_PRICES'
                        %msg               = new zcm_khr(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_khr=>negative_price )
                        %element-StartPrice   = if_abap_behv=>mk-on ) to reported-auction.
      elseif auction-StartPrice < auction-BidIncrement.
        append value #( %tky               = auction-%tky ) to failed-auction.
        append value #( %tky               = auction-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = new zcm_khr(
                                                 severity  = if_abap_behv_message=>severity-error
                                                 textid    = zcm_khr=>increment_bigger_start_price )
                        %element-BidIncrement = if_abap_behv=>mk-on
                        %element-StartPrice   = if_abap_behv=>mk-on ) to reported-auction.
      endif.
    endloop.
  endmethod.

  method setauctionstatus.
    read entities of zi_khr_auction in local mode
      entity Auction
        fields ( OverallStatus ) with corresponding #( keys )
      result data(auctions).

    delete auctions where OverallStatus is not initial.
    check auctions is not initial.

    modify entities of zi_khr_auction in local mode
    entity Auction
      update
        fields ( OverallStatus )
        with value #( for auction in auctions
                      ( %tky         = auction-%tky
                        OverallStatus = auction_status-prepairing ) )
    reported data(update_reported).

    reported = corresponding #( deep update_reported ).
  endmethod.

  method is_create_granted.
    authority-check object 'ZASTAT'
        id 'ZASTAT' dummy
        id 'ACTVT' field '01'.
    create_granted = cond #( when sy-subrc = 0 then abap_true else abap_false ).
    create_granted = abap_true. " full access for testing
  endmethod.

  method is_delete_granted.
    if has_before_image = abap_true.
      authority-check object 'ZASTAT'
          id 'ZASTAT' field overall_status
          id 'ACTVT' field '06'.
    else.
      authority-check object 'ZASTAT'
          id 'ZASTAT' dummy
          id 'ACTVT' field '06'.
    endif.

    delete_granted = cond #( when sy-subrc = 0 then abap_true else abap_false ).
    delete_granted = abap_true. " full access for testing
  endmethod.

  method is_update_granted.
    if has_before_image = abap_true.
      authority-check object 'ZASTAT'
          id 'ZASTAT' field overall_status
          id 'ACTVT' field '02'.
    else.
      authority-check object 'ZASTAT'
          id 'ZASTAT' dummy
          id 'ACTVT' field '02'.
    endif.

    update_granted = cond #( when sy-subrc = 0 then abap_true else abap_false ).
    update_granted = abap_true. " full access for testing
  endmethod.

endclass.

class lcl_behavior_saver definition inheriting from cl_abap_behavior_saver
    abstract final.

  protected section.
*  methods finalize redefinition.
**        methods check_before_save redefinition.
**        methods adjust_numbers redefinition.
*  methods save redefinition.
*        methods cleanup redefinition.
    methods save_modified redefinition.
endclass.

class lcl_behavior_saver implementation.


  method save_modified.
    if update-auction is not initial.
      loop at update-auction into data(auction).
        select auction_uuid, currency_code
        from zkhr_bid
        where auction_uuid = @auction-AuctionUuid
        into table @data(biddings).

        if biddings is not initial and biddings[ 1 ]-currency_code <> auction-CurrencyCode.
          update zkhr_bid
          set currency_code = @auction-CurrencyCode
          where auction_uuid = @auction-AuctionUuid.
        endif.


      endloop.
    endif.
  endmethod.

endclass.
