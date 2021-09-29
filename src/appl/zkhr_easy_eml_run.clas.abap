class zkhr_easy_eml_run definition
  public
  final
  create public .

  public section.

    interfaces if_oo_adt_classrun .
  protected section.
  private section.
endclass.



class zkhr_easy_eml_run implementation.


  method if_oo_adt_classrun~main.
    " read
*    read entities of zi_khr_auction
*        entity auction
*        fields ( AuctionId HolderId )
*        with value #( ( AuctionUuid = '0000000000000000000000000000000D' ) )
*        result data(auctions).
*    out->write( auctions ).
    "read by association
    read entities of zi_khr_auction
        entity auction by \_Bid
        all fields with value #( ( AuctionUuid = '00000000000000000000000000000012' ) )
        result data(biddings).
    out->write( biddings ).
  endmethod.
endclass.
