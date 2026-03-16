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

  endmethod.

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
