*"* use this source file for your ABAP unit test classes
class test_auction_beh definition final for testing
  duration short
  risk level harmless.


  private section.
    class-data environment type ref to if_cds_test_environment.
    class-data environment_db type ref to if_osql_test_environment.
    class-data auction_mock type standard table of zi_khr_auction with empty key.
    class-data bid_mock type zi_khr_bid.
    class-data customer_mock type standard table of /dmo/Customer.

    class-data cut type ref to lhc_Auction.
    class-data late_reported type response for reported late zi_khr_auction.
    class-data customer_mock_data type standard table of /dmo/customer.

    data setAuctionStatus_keys type table for determination zi_khr_auction~setAuctionStatus.
    data cancelAuction_keys type table for action import zi_khr_auction~cancelAuction.
    data startBargain_keys type table for action import zi_khr_auction~startBargaining.


    class-methods class_setup.
    class-methods class_teardown.

    methods setup.
    methods teardown.

    " determination tests
    methods setAuctionStatus for testing raising cx_static_check.

    "action tests
    methods cancelAuction for testing raising cx_static_check.
    methods startBargaining for testing raising cx_static_check.

    "validation tests
    methods validateDatesTest for testing raising cx_static_check.
    methods validateHolder for testing raising cx_static_check.
endclass.

class test_auction_beh implementation.

  method class_setup.
    create object cut for testing.
    environment = cl_cds_test_environment=>create( i_for_entity = 'ZC_KHR_AUCTION' ).
    environment->enable_double_redirection(  ).
*    environment = cl_cds_test_environment=>create( i_for_entity = 'ZI_KHR_AUCTION'
*                                                   i_dependency_list = value #( ( 'ZB_KHR_AUCTION' )
*                                                                                ( 'ZB_KHR_BID' ) )
*                                                   i_select_base_dependencies = abap_true ).
*    environment->enable_double_redirection( ).
    environment_db = cl_osql_test_environment=>create( i_dependency_list = value #( ( '/DMO/CUSTOMER' ) ) ).

    customer_mock_data = value #( ( customer_id = '228' last_name = 'Gump 228'  ) ).
  endmethod.

  method class_teardown.
    environment->destroy(  ).
    environment_db->destroy(  ).
  endmethod.

  method setup.
    environment->clear_doubles(  ).
    environment_db->clear_doubles(  ).

    environment_db->insert_test_data( customer_mock_data ).
  endmethod.

  method teardown.
    rollback entities.
  endmethod.

  method setauctionstatus.
    " Given
    auction_mock = value #( (
                    AuctionUuid = '1' ) ).
    environment->insert_test_data( auction_mock ).
    setauctionstatus_keys = value #( ( AuctionUuid = me->auction_mock[ 1 ]-AuctionUuid ) ).

    "When
    cut->setAuctionStatus(
        exporting
            keys = corresponding #( setauctionstatus_keys )
        changing
            reported = me->late_reported
     ).

    "Then
    read entities of zi_khr_auction
       entity Auction
           all fields
           with value #( ( AuctionUuid = me->auction_mock[ 1 ]-AuctionUuid ) )
           result data(auctions).



    cl_abap_unit_assert=>assert_equals(
        exporting
            act = auctions[ 1 ]-OverallStatus
            exp = 'P'
            msg = 'Wrong status!'
     ).
  endmethod.

  method cancelauction.
    " Given
    auction_mock = value #( ( AuctionUuid = '1' OverallStatus = 'R' )
                            ( AuctionUuid = '2' OverallStatus = 'S' )
                            ( AuctionUuid = '3' OverallStatus = 'P' ) ).
    environment->insert_test_data( auction_mock ).

    data result type table for action result zi_khr_auction\\Auction~cancelAuction.
    data mapped type response for mapped early zi_khr_auction.
    data failed type response for failed early zi_khr_auction.
    data reported type response for reported early zi_khr_auction.

    cancelauction_keys = value #( ( AuctionUuid = '1' ) ( AuctionUuid = '2' ) ( AuctionUuid = '3' ) ).

    "When
    cut->cancelauction(
        exporting
            keys = corresponding #( cancelauction_keys )
        changing
            result = result
            mapped = mapped
            failed = failed
            reported = reported
     ).

    "Then
    cl_abap_unit_assert=>assert_initial( msg = 'Why mapped?' act = mapped ).
    cl_abap_unit_assert=>assert_initial( msg = 'Why failed?' act = failed ).
    cl_abap_unit_assert=>assert_initial( msg = 'Why reported?' act = reported ).

    data exp like result.
    exp = value #( ( AuctionUuid = '1' %param-AuctionUuid = '1' %param-OverallStatus = 'X' )
                   ( AuctionUuid = '2' %param-AuctionUuid = '2' %param-OverallStatus = 'X' )
                   ( AuctionUuid = '3' %param-AuctionUuid = '3' %param-OverallStatus = 'X' ) ).

    " copy only fields for comparing in assert
    data act like result.
    act = corresponding #( result mapping AuctionUuid = AuctionUuid
                                   ( %param = %param mapping AuctionUuid = AuctionUuid
                                                             OverallStatus = OverallStatus
                                                                except * )
                            except *   ).
    sort act ascending by AuctionUuid.
    cl_abap_unit_assert=>assert_equals( msg = 'Cancel action result' exp = exp act = act ).

    read entity zi_khr_auction
        fields ( AuctionUuid OverallStatus ) with corresponding #( cancelauction_keys )
        result data(read_result).

    act = value #( for a in read_result ( AuctionUuid = a-AuctionUuid
                                          %param-AuctionUuid = a-AuctionUuid
                                          %param-OverallStatus = a-OverallStatus ) ).
    sort act ascending by AuctionUuid.
    cl_abap_unit_assert=>assert_equals( msg = 'Read result error' exp = exp act = act ).
  endmethod.

  method validatedatestest.
    "Given
    auction_mock = value #( ( AuctionUuid = '1' OverallStatus = 'R' BeginDate = '20210909' ExparationDate = '20211010' )
                            ( AuctionUuid = '2' OverallStatus = 'S' BeginDate = '20211010' ExparationDate = '20210505' )
                            ( AuctionUuid = '3' OverallStatus = 'P' BeginDate = '20210909' ExparationDate = '20211010') ).
    environment->insert_test_data( auction_mock ).

    data reported type response for reported late zi_khr_auction.
    data failed type response for failed late zi_khr_auction.
    data validateDates_keys type table for validation zi_khr_auction~validateDates.

    validatedates_keys = value #( ( AuctionUuid = '1' ) ( AuctionUuid = '2' ) ( AuctionUuid = '3' )  ).

    "When
    cut->validatedates(
        exporting
            keys = corresponding #( validatedates_keys )
        changing
            failed = failed
            reported = reported
     ).

    "Then
    cl_abap_unit_assert=>assert_not_initial( msg = 'Nothing failed?' act = failed ).
    cl_abap_unit_assert=>assert_equals( msg = 'Failed entry found?'
                                        act = failed-auction[ 1 ]-AuctionUuid
                                        exp = auction_mock[ 2 ]-AuctionUuid ).

    cl_abap_unit_assert=>assert_not_initial( msg = 'Nothing reported?' act = reported ).
    data(reported_auction) = reported-auction[ 2 ].
    cl_abap_unit_assert=>assert_equals( msg = 'Reported auction Uuid'
                                        act = reported_auction-AuctionUuid
                                        exp = auction_mock[ 2 ]-AuctionUuid ).
    cl_abap_unit_assert=>assert_equals( msg = 'Reported auction element'
                                        act = reported_auction-%element-begindate
                                        exp = if_abap_behv=>mk-on ).
    cl_abap_unit_assert=>assert_bound( msg = 'Message bound to wrong element?' act = reported_auction-%msg ).
  endmethod.

  method startbargaining.
    auction_mock = value #( ( AuctionUuid = '1' OverallStatus = 'D' )
                            ( AuctionUuid = '2' OverallStatus = 'P' ) ).
    environment->insert_test_data( auction_mock ).

    data result type table for action result zi_khr_auction\\Auction~startBargaining.
    data mapped type response for mapped early zi_khr_auction.
    data failed type response for failed early zi_khr_auction.
    data reported type response for reported early zi_khr_auction.

    startbargain_keys = value #( ( AuctionUuid = '1' ) ( AuctionUuid = '2' ) ).

    "When
    cut->startbargaining(
        exporting
            keys = corresponding #( startbargain_keys )
        changing
            result = result
            mapped = mapped
            failed = failed
            reported = reported
     ).

    "Then
    cl_abap_unit_assert=>assert_not_initial( msg = 'Nothing failed?' act = failed ).
    cl_abap_unit_assert=>assert_equals( msg = 'Failed entry found?'
                                        act = failed-auction[ 1 ]-AuctionUuid
                                        exp = auction_mock[ 2 ]-AuctionUuid ).
    cl_abap_unit_assert=>assert_not_initial( msg = 'Nothing reported?' act = reported ).
    data(reported_auction) = reported-auction[ 1 ].
    cl_abap_unit_assert=>assert_equals( msg = 'Reported auction Uuid'
                                        act = reported_auction-AuctionUuid
                                        exp = auction_mock[ 2 ]-AuctionUuid ).
    cl_abap_unit_assert=>assert_bound( msg = 'Message bound to wrong element?' act = reported_auction-%msg ).

    data exp like result.
    exp = value #( ( AuctionUuid = '1' %param-AuctionUuid = '1' %param-OverallStatus = 'B' ) ).

    " copy only fields for comparing in assert
    data act like result.
    act = corresponding #( result mapping AuctionUuid = AuctionUuid
                                   ( %param = %param mapping AuctionUuid = AuctionUuid
                                                             OverallStatus = OverallStatus
                                                                except * )
                            except *   ).
    sort act ascending by AuctionUuid.
    cl_abap_unit_assert=>assert_equals( msg = 'Cancel action result' exp = exp act = act ).

    read entity zi_khr_auction
        fields ( AuctionUuid OverallStatus ) with corresponding #( startbargain_keys )
        result data(read_result).

    act = value #( for a in read_result ( AuctionUuid = a-AuctionUuid
                                          %param-AuctionUuid = a-AuctionUuid
                                          %param-OverallStatus = a-OverallStatus ) ).
    exp = value #( ( AuctionUuid = '1' %param-AuctionUuid = '1' %param-OverallStatus = 'B' )
                   ( AuctionUuid = '2' %param-AuctionUuid = '2' %param-OverallStatus = 'P' ) ).
    sort act ascending by AuctionUuid.
    cl_abap_unit_assert=>assert_equals( msg = 'Read result error' exp = exp act = act ).
  endmethod.

  method validateholder.
    "Given
    auction_mock = value #( ( AuctionUuid = '1' HolderId = '228' )
                            ( AuctionUuid = '2' HolderId = '328' ) ).
    environment->insert_test_data( auction_mock ).

    data reported type response for reported late zi_khr_auction.
    data failed type response for failed late zi_khr_auction.
    data validateHolder_keys type table for validation zi_khr_auction~validateHolder.

    validateHolder_keys = value #( ( AuctionUuid = '1' ) ( AuctionUuid = '2' ) ( AuctionUuid = '3' )  ).

    select * from /dmo/customer into table @data(cuts).
    "When
    cut->validateHolder(
        exporting
            keys = corresponding #( validateHolder_keys )
        changing
            failed = failed
            reported = reported
     ).

    "Then
    cl_abap_unit_assert=>assert_not_initial( msg = 'Nothing failed?' act = failed ).
    cl_abap_unit_assert=>assert_equals( msg = 'Failed entry found?'
                                        act = failed-auction[ 1 ]-AuctionUuid
                                        exp = auction_mock[ 2 ]-AuctionUuid ).

    cl_abap_unit_assert=>assert_not_initial( msg = 'Nothing reported?' act = reported ).
    data(reported_auction) = reported-auction[ 2 ].
    cl_abap_unit_assert=>assert_equals( msg = 'Reported auction Uuid'
                                        act = reported_auction-AuctionUuid
                                        exp = auction_mock[ 2 ]-AuctionUuid ).
    cl_abap_unit_assert=>assert_equals( msg = 'Reported auction element'
                                        act = reported_auction-%element-holderid
                                        exp = if_abap_behv=>mk-on ).
    cl_abap_unit_assert=>assert_bound( msg = 'Message bound to wrong element?' act = reported_auction-%msg ).
  endmethod.

endclass.
