class zkhr_simple_run definition
  public
  final
  create public .

  public section.
    data random_month type ref to cl_abap_random_int.
    data random_day type ref to cl_abap_random_int.
    data random_price type ref to cl_abap_random_float.
    data random_customer_index type ref to cl_abap_random_int.
    data month_numbers type standard table of string.
    data day_numbers type standard table of string.
    data bid_id type i value 0.
    interfaces if_oo_adt_classrun .

    methods add_bids
      importing
        bids_amount type i.
    methods setup.
    methods get_random_date
      importing
        year          type string default '2020'
      returning
        value(result) type d.
    methods get_next_date
      importing
        one_date      type d
      returning
        value(result) type d.

    methods generate_biddings.
  protected section.
  private section.
endclass.



class zkhr_simple_run implementation.


  method if_oo_adt_classrun~main.
*    data new_entries_amount type i value 100.
*    data bids_amount type i value 10.
*
*    setup(  ).
*
*    select customer_id
*    from /dmo/customer
*    into table @data(customers)
*    up to 100 rows.
*
*    data new_entries type standard table of zkhr_auction.
*    data index type i value 10.
*    do new_entries_amount times.
*      data new_entry like line of new_entries.
*      new_entry-client = sy-mandt.
*      new_entry-auction_uuid = index.
*      new_entry-auction_id = index.
*      new_entry-begin_date = get_random_date(  ).
*      new_entry-end_date = get_next_date( new_entry-begin_date ).
*      new_entry-exparation_date = get_next_date( new_entry-end_date ).
*      new_entry-currency_code = 'USD'.
*      new_entry-start_price = random_price->get_next(  ) * 1000.
*      new_entry-bid_increment = random_price->get_next(  ) * 100.
*      new_entry-overall_status = 'P'.
*      new_entry-holder_id = customers[ random_customer_index->get_next(  ) ].
*      insert into zkhr_auction values @new_entry.
*      index += 1.
*    enddo.
*    out->write( |Generating done.| ).

    generate_biddings(  ).
  endmethod.
  method add_bids.

  endmethod.

  method setup.
    random_day = cl_abap_random_int=>create( seed = conv i( sy-uzeit )
                                             min = 1
                                             max = 30 ).
    random_month = cl_abap_random_int=>create( seed = conv i( sy-uzeit )
                                               min = 1
                                               max = 12 ).
    random_price = cl_abap_random_float=>create( seed = conv i( sy-uzeit ) ).
    random_customer_index = cl_abap_random_int=>create( seed = conv i( sy-uzeit )
                                                          min = 1
                                                          max = 99 ).
    month_numbers = value #( ( |01| )
                             ( |02| )
                             ( |03| )
                             ( |04| )
                             ( |05| )
                             ( |06| )
                             ( |07| )
                             ( |08| )
                             ( |09| )
                             ( |10| )
                             ( |11| )
                             ( |12| ) ).
    day_numbers = value #( ( |01| )
                           ( |02| )
                           ( |03| )
                           ( |04| )
                           ( |05| )
                           ( |06| )
                           ( |07| )
                           ( |08| )
                           ( |09| ) ).
    do  21 times.
      insert conv #( sy-tabix + 10 ) into table day_numbers.
    enddo.
  endmethod.

  method get_random_date.
    if year is not initial.
      data month type  string value '01'.
      data dat type string value '01'.
      if random_month is bound.
        month = month_numbers[ random_month->get_next(  ) ].
      endif.
      if random_day is bound.
        dat = day_numbers[ random_day->get_next(  ) ].
      endif.
      result = |{ year }{ month }{ dat }|.
    endif.
    if result is initial.
      result = sy-datum.
    endif.
  endmethod.



  method get_next_date.
    if one_date is not initial.
      data(year) = substring( val = one_date off = 0 len = 4 ).
      data(new_date) = get_random_date( year ).
      if one_date > new_date.
        new_date = |{ conv i( substring( val = conv string( new_date ) off = 0 len = 4 ) ) + 1 }| &&
                   |{ substring( val = new_date off = 4 len = 2 ) }{ substring( val = new_date off = 6 len = 2 ) }|.
      endif.
      result = new_date.
    else.
      result = sy-datum.
    endif.
  endmethod.



  method generate_biddings.
*    data biddings type biddings_table.
*    if auction is not initial.
*        do amount times.
*            data bid type bid_struct.
*            bid-client = sy-mandt.
*            bid-auction_uuid = auction-auction_uuid.
*            bid-bidding_id = me->bid_id.
*            me->bid_id += 1.
*            bid-owner_id = random_customer_index->get_next(  ).
*            bid-bid_date = get_next_date( auction-begin_date ).
*            bid-bid_amount = random_price->get_next(  ) * 100.
*            bid-currency_code = auction-currency_code.
*
*
*        enddo.
*    endif.
*    select * from biddings into corresponding fields of table zkhr_bid.
    data new_entries_amount type i value 100.
    data bids_amount type i value 10.

    setup(  ).

    select customer_id
    from /dmo/customer
    into table @data(customers)
    up to 100 rows.
    data create type table for create zi_khr_auction.
    data biddings type standard table of zi_khr_bid with default key.
    create = value #(  ).

    data new_entry like line of create.
    data index type i value 1.
    do new_entries_amount times.
      new_entry-AuctionUuid = index.
      new_entry-AuctionId = index.
      new_entry-BeginDate = get_random_date(  ).
      new_entry-EndDate = get_next_date( new_entry-BeginDate ).
      new_entry-ExparationDate = get_next_date( new_entry-EndDate ).
      new_entry-CurrencyCode = 'USD'.
      new_entry-StartPrice = random_price->get_next(  ) * 1000.
      new_entry-BidIncrement = random_price->get_next(  ) * 100.
      new_entry-OverallStatus = 'P'.
      new_entry-HolderId = customers[ random_customer_index->get_next(  ) ].
      data bid like line of biddings.
      do bids_amount times.
        bid-AuctionUuid = new_entry-AuctionUuid.
        bid-BidAmount = random_price->get_next(  ) * 100.
        bid-BidDate = sy-datum.
        bid-BiddingId = bid_id.
        bid-BiddingUuid = bid_id.
        bid_id += 1.
        insert bid into table biddings.
      enddo.
      modify entities of zi_khr_auction
        entity Auction
            create auto fill cid
                set fields with value #( ( corresponding #( new_entry ) ) )
            create by \_Bid auto fill cid
                set fields with value #( ( %target = corresponding #( biddings ) ) ).

    enddo.

  endmethod.

endclass.
