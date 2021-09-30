class zcm_khr definition
  public
  inheriting from cx_static_check
  final
  create public .

  public section.

    interfaces if_abap_behv_message .
    interfaces if_t100_dyn_msg .
    interfaces if_t100_message .

    constants:
      begin of date_interval,
        msgid type symsgid value 'ZKHR_MSG',
        msgno type symsgno value '001',
        attr1 type scx_attrname value 'BEGINDATE',
        attr2 type scx_attrname value 'EXPDATE',
        attr3 type scx_attrname value 'AUCTIONID',
        attr4 type scx_attrname value '',
      end of date_interval.

    constants:
      begin of exp_date_after_begin,
        msgid type symsgid value 'ZKHR_MSG',
        msgno type symsgno value '002',
        attr1 type scx_attrname value 'EXPDATE',
        attr2 type scx_attrname value 'ENDDATE',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of exp_date_after_begin.

      constants:
      begin of begin_date_before_sys,
        msgid type symsgid value 'ZKHR_MSG',
        msgno type symsgno value '010',
        attr1 type scx_attrname value 'BEGINDATE',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of begin_date_before_sys.

    constants:
      begin of owner_unknown,
        msgid type symsgid value 'ZKHR_MSG',
        msgno type symsgno value '003',
        attr1 type scx_attrname value 'OWNERID',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of owner_unknown.
    constants:
      begin of holder_unknown,
        msgid type symsgid value 'ZKHR_MSG',
        msgno type symsgno value '004',
        attr1 type scx_attrname value 'HOLDERID',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of holder_unknown.
    constants:
      begin of unautharized,
        msgid type symsgid value 'ZKHR_MSG',
        msgno type symsgno value '005',
        attr1 type scx_attrname value 'EXPDATE',
        attr2 type scx_attrname value 'ENDDATE',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of unautharized.

    constants:
      begin of unsold_auction,
        msgid type symsgid value 'zkhr_msg',
        msgno type symsgno value '006',
        attr1 type scx_attrname value 'AUCTIONID',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of unsold_auction.

    constants:
      begin of canceled_auction,
        msgid type symsgid value 'ZKHR_MSG',
        msgno type symsgno value '008',
        attr1 type scx_attrname value 'AUCTIONID',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of canceled_auction.

    constants:
      begin of unready_auction,
        msgid type symsgid value 'ZKHR_MSG',
        msgno type symsgno value '009',
        attr1 type scx_attrname value 'AUCTIONID',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of unready_auction.

    constants:
      begin of negative_price,
        msgid type symsgid value 'ZKHR_MSG',
        msgno type symsgno value '011',
        attr1 type scx_attrname value '',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of negative_price.

    constants:
      begin of increment_bigger_start_price,
        msgid type symsgid value 'ZKHR_MSG',
        msgno type symsgno value '012',
        attr1 type scx_attrname value '',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of increment_bigger_start_price.

    constants:
      begin of negative_bid,
        msgid type symsgid value 'ZKHR_MSG',
        msgno type symsgno value '013',
        attr1 type scx_attrname value '',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of negative_bid.

    constants:
      begin of low_bid_amount,
        msgid type symsgid value 'ZKHR_MSG',
        msgno type symsgno value '014',
        attr1 type scx_attrname value 'STARTPRICE',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of low_bid_amount.

    methods constructor
      importing
        severity   type if_abap_behv_message=>t_severity default if_abap_behv_message=>severity-error
        textid     like if_t100_message=>t100key optional
        previous   type ref to cx_root optional
        begindate  type /dmo/begin_date optional
        enddate    type /dmo/end_date optional
        expdate    type /dmo/end_date optional
        auctionid  type zkhr_auction_id optional
        customerid type /dmo/customer_id optional
        startprice type zkhr_start_price optional
        .

    data begindate type /dmo/begin_date read-only.
    data enddate type /dmo/end_date read-only.
    data expdate type /dmo/end_date read-only.
    data auctionid type string read-only.
    data ownerid type string read-only.
    data holderid type string read-only.
    data startprice type string read-only.
  protected section.
  private section.
endclass.



class zcm_khr implementation.


  method constructor ##ADT_SUPPRESS_GENERATION.
    call method super->constructor
      exporting
        previous = previous.

    me->if_abap_behv_message~m_severity = severity.
    me->begindate = begindate.
    me->enddate = enddate.
    me->expdate = expdate.
    me->auctionid = |{ auctionid alpha = out }|.
    me->ownerid = |{ customerid alpha = out }|.
    me->holderid = |{ customerid alpha = out }|.
    me->startprice = |{ startprice }|.
    clear me->textid.
    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.

    endif.
  endmethod.
endclass.
