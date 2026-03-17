CLASS lsc_zr_ge289116 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.


CLASS lsc_zr_ge289116 IMPLEMENTATION.
  METHOD save_modified.
    DATA events_to_be_raised TYPE TABLE FOR EVENT zr_GE289116~statusUpdated.

    IF create-ShoppingCart IS NOT INITIAL.
      LOOP AT create-ShoppingCart INTO DATA(create_shoppingcart).
        IF     create_shoppingcart-%control-OverallStatus = if_abap_behv=>mk-on
          " AND create_shoppingcart-OverallStatus = zbp_r_GE289116=>order_state-in_process.
           AND create_shoppingcart-OverallStatus          = zbp_r_GE289116=>order_state-saved.
          zcl_GE289116_start_bgpf=>run_via_bgpf_tx_uncontrolled( i_rap_bo_key = create_shoppingcart-OrderUUID ).
        ENDIF.
      ENDLOOP.
    ENDIF.

    " the salesorder and the status is updated via BGPF
    IF update-ShoppingCart IS NOT INITIAL.
      LOOP AT update-ShoppingCart INTO DATA(update_shoppingcart).
        IF update_shoppingcart-%control-SalesOrderStatus = if_abap_behv=>mk-on.
          CLEAR events_to_be_raised.
          APPEND INITIAL LINE TO events_to_be_raised.
          events_to_be_raised[ 1 ] = CORRESPONDING #( update_shoppingcart ).
          RAISE ENTITY EVENT zr_GE289116~statusUpdated FROM events_to_be_raised.
        ENDIF.

        IF     update_shoppingcart-%control-OverallStatus = if_abap_behv=>mk-on
          " AND update_shoppingcart-OverallStatus = zbp_r_GE289116=>order_state-in_process.
           AND update_shoppingcart-OverallStatus          = zbp_r_GE289116=>order_state-saved.
          zcl_GE289116_start_bgpf=>run_via_bgpf_tx_uncontrolled( i_rap_bo_key = update_shoppingcart-OrderUUID ).
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.



ENDCLASS.

CLASS lhc_zr_ge289116 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ShoppingCart
        RESULT result.

    METHODS setStatusToNew FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ShoppingCart~setStatusToNew.

    METHODS calculateOrderID FOR DETERMINE ON SAVE
      IMPORTING keys FOR ShoppingCart~calculateOrderID.

    METHODS setStatusToSaved FOR DETERMINE ON SAVE
      IMPORTING keys FOR ShoppingCart~setStatusToSaved.
ENDCLASS.

CLASS lhc_zr_ge289116 IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD setStatusToNew.



    DATA update TYPE TABLE FOR UPDATE zr_GE289116\\ShoppingCart.
    DATA update_line TYPE STRUCTURE FOR UPDATE zr_GE289116\\ShoppingCart.

    READ ENTITIES OF zr_GE289116 IN LOCAL MODE
      ENTITY ShoppingCart
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    DELETE entities WHERE OverallStatus IS NOT INITIAL.
    CHECK entities IS NOT INITIAL.

    LOOP AT entities INTO DATA(entity).
      update_line-%tky          = entity-%tky.
      update_line-OverallStatus = zbp_r_GE289116=>order_state-new.
      APPEND update_line TO update.
    ENDLOOP.

    MODIFY ENTITIES OF zr_GE289116 IN LOCAL MODE
      ENTITY ShoppingCart
        UPDATE FIELDS ( OverallStatus )
        WITH update
      REPORTED DATA(update_reported).

    "Set the changing parameter
    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD calculateOrderID.

    DATA update TYPE TABLE FOR UPDATE zr_GE289116\\ShoppingCart.
    DATA update_line TYPE STRUCTURE FOR UPDATE zr_GE289116\\ShoppingCart .

    READ ENTITIES OF zr_GE289116 IN LOCAL MODE
        ENTITY ShoppingCart
          ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DELETE entities WHERE orderID IS NOT INITIAL.
    CHECK entities IS NOT INITIAL.

    SELECT MAX( order_ID ) FROM zGE289116 INTO @DATA(max_object_id).

    LOOP AT entities INTO DATA(entity).
      update_line-%tky    = entity-%tky.
      update_line-orderID = max_object_id + sy-index.
      APPEND update_line TO update.
    ENDLOOP.

    MODIFY ENTITIES OF zr_GE289116 IN LOCAL MODE
      ENTITY ShoppingCart
        UPDATE FIELDS ( orderID )
          WITH update
    REPORTED DATA(update_reported).

    "Set the changing parameter
    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD setStatusToSaved.

    DATA update TYPE TABLE FOR UPDATE zr_GE289116\\ShoppingCart.
    DATA update_line TYPE STRUCTURE FOR UPDATE zr_GE289116\\ShoppingCart .

    READ ENTITIES OF zr_GE289116 IN LOCAL MODE
       ENTITY ShoppingCart
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity) WHERE OverallStatus = zbp_r_GE289116=>order_state-new.
      update_line-%tky    = entity-%tky.
      update_line-OverallStatus = zbp_r_GE289116=>order_state-saved.
      APPEND update_line TO update.
    ENDLOOP.

    MODIFY ENTITIES OF zr_GE289116 IN LOCAL MODE
     ENTITY ShoppingCart
       UPDATE FIELDS ( OverallStatus )
         WITH update
    REPORTED DATA(update_reported).

    "Set the changing parameter
    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

ENDCLASS.
