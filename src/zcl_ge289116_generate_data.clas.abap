CLASS zcl_GE289116_generate_data DEFINITION
PUBLIC
FINAL
CREATE PUBLIC .

PUBLIC SECTION.
INTERFACES if_oo_adt_classrun.

PROTECTED SECTION.
PRIVATE SECTION.
METHODS: delete_demo_data.
METHODS: generate_demo_data.

ENDCLASS.

CLASS zcl_GE289116_generate_data IMPLEMENTATION.
METHOD if_oo_adt_classrun~main.

delete_demo_data(  ).
out->write( 'Table entries deleted' ).

generate_demo_data(  ).
out->write( 'Demo data was generated' ).

ENDMETHOD.

METHOD delete_demo_data.
DELETE FROM zGE289116.
COMMIT WORK.
ENDMETHOD.


METHOD generate_demo_data.


DATA: demo_data_line TYPE zGE289116,
      demo_data      TYPE STANDARD TABLE OF zGE289116.
DATA: long_time_stamp TYPE timestampl.

DATA: lv_idx TYPE i,
      lv_order_id TYPE char8,
      lt_items TYPE TABLE OF char8,
      lv_item TYPE char8.

lt_items = VALUE #( ( 'HT-1001' ) ( 'HT-1002' ) ( 'HT-1003' ) ( 'HT-1004' ) ( 'HT-1005' )
                    ( 'HT-1006' ) ( 'HT-1007' ) ( 'HT-1008' ) ( 'HT-1009' ) ( 'HT-1010' ) ).

DO 10 TIMES.
  lv_idx = sy-index.
  lv_order_id = |{ lv_idx WIDTH = 8 PAD = '0' }|.
  lv_item = lt_items[ lv_idx ].

  demo_data_line-client = '100'.
  demo_data_line-order_uuid = xco_cp=>uuid( )->value.
  demo_data_line-order_id = lv_order_id.
  demo_data_line-ordered_item = lv_item.
  demo_data_line-order_quantity = |{ 1 + lv_idx }|.  "Example, will be 2,3,...11
  demo_data_line-total_price = |{ ( 10 + lv_idx * 5 ) CURRENCY = 'EUR' }|.
  demo_data_line-currency = 'EUR'.
  demo_data_line-requested_delivery_date = xco_cp=>sy->date( )->as( xco_cp_time=>format->abap )->value.
  demo_data_line-created_by = xco_cp=>sy->user( )->name.
  demo_data_line-created_at = long_time_stamp.
  demo_data_line-last_changed_by = xco_cp=>sy->user( )->name.
  demo_data_line-last_changed_at = long_time_stamp.
  demo_data_line-local_last_changed_at = long_time_stamp.

  APPEND demo_data_line TO demo_data.
ENDDO.

INSERT zGE289116 FROM TABLE @demo_data.
COMMIT WORK.

CLEAR demo_data.
ENDMETHOD.

ENDCLASS.
