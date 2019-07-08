codeunit 6014554 "Meta Trigger Management"
{
    // NPR4.14/RMT/20150210 Case 198862 - Object created. Manages valid keywords - both static and from meta triggers
    // NPR4.14/RMT/20150210 Case 203161 - New Keyword 'QUICK_PAYMENT': creates a payment line and ends the current sales
    //                                    New Keyword 'HIDE_INPUT_DIALOG', 'SHOW_INPUT_DIALOG': toggles the input dialog on and off for quick payments
    // NPR4.14/RMT/20150608 Case 216519 - New keyword 'SALESDOC_CR_MSG'
    // NPR4.14/RMT/20150626 Case 216519 - New keyword 'SALESDOC_RET_AMT'
    //                                    possible to have parameter at end of meta trigger name
    // NPR4.14/RMT/20150727 Case 216519 - New keyword 'SALESDOC_DEPOSIT_DLG'
    // NPR4.14/MMV/20150728 CASE 216519 - New keywords 'SALESDOC_OUTPUT_DOCUMENT', 'SALESDOC_OPEN_PAGE', 'SALESDOC_ORD_TYPE'
    // MM1.01/TSA/20151222 CASE 230149 - New keyword 'MM_SCAN_CARD'
    // TM1.09/TSA/20160202  CASE 232952 - Added function to support scanning a ticket
    // NPR5.20/BR/20160217  CASE 231481 - New keywords 'TERMINAL_OPENSHIFT'
    // NPR5.20/TTH/20160303 CASE 235900 Shortened text constants Text149,Text153 and Text157.
    // NPR5.22/BR/20160412 CASE 231481 - NEW keywords 'TERMINAL_OFFLINE'
    // NPR5.22/BR/20160422 CASE 231481 - NEW keywords 'TERMINAL_INSTALL'
    // NPR5.22/MMV/20160425 CASE 232067  New keywords for customer location mgt.
    // NPR5.30/BHR /20170207 CASE 265676 Trim description
    // NPR5.32/BHR /20170525  CASE 270885 Add trigger for Initialization of sales doc


    trigger OnRun()
    begin
    end;

    var
        Keyword: array [200] of Text;
        Description: array [200] of Text;
        IsInitialized: Boolean;
        Text001: Label 'Print Last Receipt';
        Text002: Label 'Print Last Receipt (A4)';
        Text003: Label 'Print Last Receipt Debit';
        Text004: Label 'Print Last';
        Text005: Label 'Register Lock';
        Text006: Label 'Register Change';
        Text007: Label 'Receipt to NP order';
        Text008: Label 'Receipt to customization';
        Text009: Label 'Shipment to NP order';
        Text010: Label 'Save sale';
        Text011: Label 'Cancel sale';
        Text012: Label 'Toggle sales VAT yes/no';
        Text013: Label 'Sale functions';
        Text014: Label 'Discount functions';
        Text015: Label 'Prints';
        Text016: Label 'Quantity on POS';
        Text017: Label 'Negate Quantity';
        Text018: Label 'Item Groups';
        Text019: Label 'Sales return type';
        Text020: Label 'Out payment';
        Text021: Label 'Insert payment';
        Text022: Label 'Insert cash payment';
        Text023: Label 'Sales gift voucher';
        Text024: Label 'Sales city gift voucher';
        Text025: Label 'Insert insurance';
        Text026: Label 'Item ledger entries';
        Text027: Label 'Item sample send';
        Text028: Label 'Item sample get';
        Text029: Label 'NP order send';
        Text030: Label 'NP order get';
        Text031: Label 'Rent contract send';
        Text032: Label 'Purchase contract send';
        Text033: Label 'Tailor send';
        Text034: Label 'Tailor get';
        Text035: Label 'Quote send';
        Text036: Label 'Quote get';
        Text037: Label 'Reverse sale';
        Text038: Label 'Cancel sale';
        Text039: Label 'Import sale';
        Text040: Label 'Balance register';
        Text041: Label 'Scanner get sale';
        Text042: Label 'Scan member card';
        Text043: Label 'Serial number';
        Text044: Label 'Serial number arb';
        Text045: Label 'Insert comment';
        Text046: Label 'Edit comment';
        Text047: Label 'Get repair';
        Text048: Label 'Return sale';
        Text049: Label 'Item inventory';
        Text050: Label 'Item inventory all';
        Text051: Label 'Edit item card';
        Text052: Label 'Goto sale';
        Text053: Label 'Save sale';
        Text054: Label 'Get sale';
        Text055: Label 'Goto payment';
        Text056: Label 'Copy item';
        Text057: Label 'Sale to POS';
        Text058: Label 'Terminal open/close';
        Text059: Label 'Terminal end of day';
        Text060: Label 'Terminal unlock';
        Text061: Label 'Customer';
        Text062: Label 'Customer item ledger entries';
        Text063: Label 'Customer CRM';
        Text064: Label 'Customer standard';
        Text065: Label 'Remove customer';
        Text066: Label 'Set customer';
        Text067: Label 'Customer pay';
        Text068: Label 'Debit information';
        Text069: Label 'Customer ledger entries';
        Text070: Label 'Customer payment';
        Text071: Label 'Customer information';
        Text072: Label 'Customer staff';
        Text073: Label 'Customer parameters';
        Text074: Label 'Customer ask about att. and ref.';
        Text075: Label 'Turnover sale';
        Text076: Label 'Turnover report';
        Text077: Label 'Turnover statistics';
        Text078: Label 'Line amount';
        Text079: Label 'Line unit price';
        Text080: Label 'Total amount';
        Text081: Label 'Total discount';
        Text082: Label 'Total discount percent abs';
        Text083: Label 'Total discount percent reel';
        Text084: Label 'Discount percent cr';
        Text085: Label 'Line discount percent abs';
        Text086: Label 'Line discount percent reel';
        Text087: Label 'Block line discount';
        Text088: Label 'Line discount amount';
        Text089: Label 'Init sale';
        Text090: Label 'Set description';
        Text091: Label 'Print exchange label line one';
        Text092: Label 'Print exchange label';
        Text093: Label 'Print exchange label all';
        Text094: Label 'Print exchange label line all';
        Text095: Label 'Print exchange label selected';
        Text096: Label 'Print exchange label package';
        Text097: Label 'Print override';
        Text098: Label 'Print item label';
        Text099: Label 'Print item label all';
        Text100: Label 'Payment functions';
        Text101: Label 'Payment type';
        Text102: Label 'Payment with gift voucher';
        Text103: Label 'Payment with credit voucher';
        Text104: Label 'Create credit voucher';
        Text105: Label 'Hide quick payment input dialog';
        Text106: Label 'Show quick payment input dialog';
        Text107: Label 'Make quick payment';
        Text108: Label 'Push enter';
        Text109: Label 'Item functions';
        Text110: Label 'Quit sale';
        Text111: Label 'Open register';
        Text112: Label 'Goto line';
        Text113: Label 'Delete line';
        Text114: Label 'Lookup';
        Text115: Label 'Information';
        Text116: Label 'Zoom';
        Text117: Label 'Sales dimensions';
        Text118: Label 'Tax free';
        Text119: Label 'Shop in shop';
        Text120: Label 'View audit roll';
        Text121: Label 'Go back';
        Text122: Label 'Goto root';
        Text123: Label 'Repeat entry';
        Text124: Label 'Terminal payment';
        Text125: Label 'Sales document ask on';
        Text126: Label 'Sales document ask off';
        Text127: Label 'Sales document print on';
        Text128: Label 'Sales document print off';
        Text129: Label 'Sales document  invoice on';
        Text130: Label 'Sales document invoice off';
        Text131: Label 'Sales document post on';
        Text132: Label 'Sales document post off';
        Text133: Label 'Sales document receive on';
        Text134: Label 'Sales document receive off';
        Text135: Label 'Sales document ship on';
        Text136: Label 'Sales document ship off';
        Text137: Label 'Sales document type order';
        Text138: Label 'Sales document type invoice';
        Text139: Label 'Sales document type return order';
        Text140: Label 'Sales document credit memo';
        Text141: Label 'Sales document write audit roll';
        Text142: Label 'Sales document process';
        Text143: Label 'Import sales quote';
        Text144: Label 'Import sales invoice';
        Text145: Label 'Import sales order';
        Text146: Label 'Import credit memo';
        Text147: Label 'Import return order';
        Text148: Label 'Sales document show creation message';
        Text149: Label 'Sales doc. amount to POS. Use ?xx for pct.';
        Text150: Label 'Saves the transaction to the database';
        Text151: Label 'Import Sales Order Amount';
        Text152: Label 'Show deposit dialog';
        Text153: Label 'Send Sales Doc. to CU. Use ?xx for CU No.';
        Text154: Label 'Open sales document page';
        Text155: Label 'Test sale before creating sales doc.';
        Text156: Label 'Order Type (0=std.,1=Order,2=Lending)';
        Text157: Label 'Import Order Type (0=std.,1=Order,2=Lend)';
        Text158: Label 'Scan Membercard';
        Text159: Label 'Scan Ticketnumber';
        Text160: Label 'Change Register';
        Text161: Label 'Open terminal workshift.';
        Text162: Label 'Auxiliary Functions Pepper.';
        Text163: Label 'Set terminal offline status.';
        Text164: Label 'Install the payment terminal.';
        Text165: Label 'Import from customer location';
        Text166: Label 'Export to customer location';
        Text167: Label 'Print lines at customer location';
        Text168: Label 'Show customer location list';
        Text169: Label 'Init sale Order';

    procedure Init()
    begin
        if IsInitialized then
          exit;

        Keyword[1] := 'PRINT_LAST_RECEIPT';                       Description[1]  := Text001;
        Keyword[2] := 'PRINT_LAST_RECEIPT_A4';                    Description[2]  := Text002;
        Keyword[3] := 'PRINT_LAST_RECEIPT_DEBIT';                 Description[3]  := Text003;
        Keyword[4] := 'PRINT_LAST';                               Description[4]  := Text004;
        Keyword[5] := 'REGISTER_LOCK';                            Description[5]  := Text005;
        Keyword[6] := 'REGISTER_CHANGE';                          Description[6]  := Text006;
        Keyword[7] := 'RECEIPT2NPORDER';                          Description[7]  := Text007;
        Keyword[8] := 'RECEIPT2CUSTIMIZATION';                    Description[8]  := Text008;
        Keyword[9] := 'SHIPMENT2NPORDER';                         Description[9]  := Text009;
        Keyword[10] := 'SALE_SAVE';                               Description[10] := Text010;
        Keyword[11] := 'CANCEL_SALE';                             Description[11] := Text011;
        Keyword[12] := 'TOGGLE_SALEVAT_YN';                       Description[12] := Text012;
        Keyword[13] := 'FUNCTIONS_SALE';                          Description[13] := Text013;
        Keyword[14] := 'FUNCTIONS_DISCOUNT';                      Description[14] := Text014;
        Keyword[15] := 'PRINTS';                                  Description[15] := Text015;
        Keyword[16] := 'QUANTITY_POS';                            Description[16] := Text016;
        Keyword[17] := 'QUANTITY_NEG';                            Description[17] := Text017;
        Keyword[18] := 'ITEMGROUPS';                              Description[18] := Text018;
        Keyword[19] := 'TYPE_SALE_RETURN';                        Description[19] := Text019;
        Keyword[20] := 'OUT_PAYMENT';                             Description[20] := Text020;
        Keyword[21] := 'INSERT_PAYMENT';                          Description[21] := Text021;
        Keyword[22] := 'INSERT_PAYMENT_CASH';                     Description[22] := Text022;
        Keyword[23] := 'SALE_GIFTVOUCHER';                        Description[23] := Text023;
        Keyword[24] := 'SALE_CITYGIFTVOUCHER';                    Description[24] := Text024;
        Keyword[25] := 'INSURANCE_INSERT';                        Description[25] := Text025;
        Keyword[26] := 'ITEM_LEDGERENTRIES';                      Description[26] := Text026;
        Keyword[27] := 'SAMPLING_SEND';                           Description[27] := Text027;
        Keyword[28] := 'SAMPLING_GET';                            Description[28] := Text028;
        Keyword[29] := 'NPORDER_SEND';                            Description[29] := Text029;
        Keyword[30] := 'NPORDER_GET' ;                            Description[30] := Text030;
        Keyword[31] := 'CONTRACTRENT_SEND';                       Description[31] := Text031;
        Keyword[32] := 'CONTRACTPURCH_SEND';                      Description[32] := Text032;
        Keyword[33] := 'TAILOR_SEND';                             Description[33] := Text033;
        Keyword[34] := 'TAILOR_GET' ;                             Description[34] := Text034;
        Keyword[35] := 'QUOTE_SEND';                              Description[35] := Text035;
        Keyword[36] := 'QUOTE_GET';                               Description[36] := Text036;
        Keyword[37] := 'SALE_REVERSE';                            Description[37] := Text037;
        Keyword[38] := 'SALE_ANNULL';                             Description[38] := Text038;
        Keyword[39] := 'IMPORT_SALE';                             Description[39] := Text039;
        Keyword[40] := 'BALANCE_REGISTER';                        Description[40] := Text040;
        Keyword[41] := 'SCANNER_GET_SALE';                        Description[41] := Text041;
        Keyword[42] := 'SCANNER_MEMBERCARD';                      Description[42] := Text042;
        Keyword[43] := 'SERIAL_NUMBER';                           Description[43] := Text043;
        Keyword[44] := 'SERIAL_NUMBER_ARB';                       Description[44] := Text044;
        Keyword[45] := 'COMMENT_INSERT';                          Description[45] := Text045;
        Keyword[46] := 'COMMENT_EDIT';                            Description[46] := Text046;
        Keyword[47] := 'REPAIR_GET';                              Description[47] := Text047;
        Keyword[48] := 'RETURN_SALE';                             Description[48] := Text048;
        Keyword[49] := 'ITEM_INVENTORY';                          Description[49] := Text049;
        Keyword[50] := 'ITEM_INVENTORY_ALL';                      Description[50] := Text050;
        Keyword[51] := 'ITEMCARD_EDIT';                           Description[51] := Text051;
        Keyword[52] := 'GOTO_SALE';                               Description[52] := Text052;
        Keyword[53] := 'SAVE_SALE';                               Description[53] := Text053;
        Keyword[54] := 'GET_SALE';                                Description[54] := Text054;
        Keyword[55] := 'GOTO_PAYMENT';                            Description[55] := Text055;
        Keyword[56] := 'COPY_ITEM';                               Description[56] := Text056;
        Keyword[57] := 'SALE2POS';                                Description[57] := Text057;
        Keyword[58] := 'TERMINAL_OPENCLOSE';                      Description[58] := Text058;
        Keyword[59] := 'TERMINAL_ENDOFDAY';                       Description[59] := Text059;
        Keyword[60] := 'TERMINAL_UNLOCK';                         Description[60] := Text060;
        Keyword[61] := 'CUSTOMER';                                Description[61] := Text061;
        Keyword[62] := 'CUSTOMER_ILE';                            Description[62] := Text062;
        Keyword[63] := 'CUSTOMER_CRM';                            Description[63] := Text063;
        Keyword[64] := 'CUSTOMER_STD';                            Description[64] := Text064;
        Keyword[65] := 'CUSTOMER_REMOVE';                         Description[65] := Text065;
        Keyword[66] := 'CUSTOMER_SET';                            Description[66] := Text066;
        Keyword[67] := 'CUSTOMER_PAY';                            Description[67] := Text067;
        Keyword[68] := 'DEBIT_INFO';                              Description[68] := Text068;
        Keyword[69] := 'CUSTOMER_CLE';                            Description[69] := Text069;
        Keyword[70] := 'CUSTOMER_PAYMENT';                        Description[70] := Text070;
        Keyword[71] := 'CUSTOMER_INFO';                           Description[71] := Text071;
        Keyword[72] := 'CUSTOMER_STAFF';                          Description[72] := Text072;
        Keyword[73] := 'CUSTOMER_PARAM';                          Description[73] := Text073;
        Keyword[74] := 'CUSTOMER_ASKATTREF';                      Description[74] := Text074;
        Keyword[75] := 'TURNOVER_SALE';                           Description[75] := Text075;
        Keyword[76] := 'TURNOVER_REPORT';                         Description[76] := Text076;
        Keyword[77] := 'TURNOVER_STATS';                          Description[77] := Text077;
        Keyword[78] := 'LINE_AMOUNT';                             Description[78] := Text078;
        Keyword[79] := 'LINE_UNITPRICE';                          Description[79] := Text079;
        Keyword[80] := 'TOTAL_AMOUNT';                            Description[80] := Text080;
        Keyword[81] := 'TOTAL_DISCOUNT';                          Description[81] := Text081;
        Keyword[82] := 'TOTAL_DISCOUNTPCT_ABS';                   Description[82] := Text082;
        Keyword[83] := 'TOTAL_DISCOUNTPCT_REL';                   Description[83] := Text083;
        Keyword[84] := 'DISCOUNTPCT_CR';                          Description[84] := Text084;
        Keyword[85] := 'LINE_DISCOUNTPCT_ABS';                    Description[85] := Text085;
        Keyword[86] := 'LINE_DISCOUNTPCT_REL';                    Description[86] := Text086;
        Keyword[87] := 'LINE_DISCOUNT_BLOCK';                     Description[87] := Text087;
        Keyword[88] := 'LINE_DISCOUNT_AMOUNT';                    Description[88] := Text088;
        Keyword[89] := 'SALE_INIT';                               Description[89] := Text089;
        Keyword[90] := 'SET_DESCRIPTION';                         Description[90] := Text090;
        Keyword[91] := 'PRINT_EXCHLABEL_LINE_ONE';                Description[91] := Text091;
        Keyword[92] := 'PRINT_EXCHLABEL     ';                    Description[92] := Text092;
        Keyword[93] := 'PRINT_EXCHLABEL_ALL';                     Description[93] := Text093;
        Keyword[94] := 'PRINT_EXCHLABEL_LINE_ALL';                Description[94] := Text094;
        Keyword[95] := 'PRINT_EXCHLABEL_SELECT';                  Description[95] := Text095;
        Keyword[96] := 'PRINT_EXCHLABEL_PACKAGE';                 Description[96] := Text096;
        Keyword[97] := 'PRINT_OVERRIDE';                          Description[97] := Text097;
        Keyword[98] := 'PRINT_ITEM_LABEL';                        Description[98] := Text098;
        Keyword[99] := 'PRINT_ITEM_LABEL_ALL';                    Description[99] := Text099;
        Keyword[100] := 'FUNCTIONS_PAYMENT';                      Description[100] := Text100;
        Keyword[101] := 'PAYMENT_TYPE';                           Description[101] := Text101;
        Keyword[102] := 'PAYMENT_GIFTVOUCHER';                    Description[102] := Text102;
        Keyword[103] := 'PAYMENT_CREDITVOUCHER';                  Description[103] := Text103;
        Keyword[104] := 'CREDITVOUCHER_CREATE';                   Description[104] := Text104;
        //-NPR4.14
        Keyword[105] := 'HIDE_INPUT_DIALOG';                      Description[105] := Text105;
        Keyword[106] := 'SHOW_INPUT_DIALOG';                      Description[106] := Text106;
        Keyword[107] := 'QUICK_PAYMENT';                          Description[107] := Text107;
        //+NPR4.14
        Keyword[108] := 'ENTERPUSH';                              Description[108] := Text108;
        Keyword[109] := 'FUNCTIONS_ITEM';                         Description[109] := Text109;
        Keyword[110] := 'SALE_QUIT';                              Description[110] := Text110;
        Keyword[111] := 'REGISTER_OPEN';                          Description[111] := Text111;
        Keyword[112] := 'GOTO_LINE';                              Description[112] := Text112;
        Keyword[113] := 'DELETE_LINE';                            Description[113] := Text113;
        Keyword[114] := 'LOOKUP';                                 Description[114] := Text114;
        Keyword[115] := 'INFO';                                   Description[115] := Text115;
        Keyword[116] := 'ZOOM';                                   Description[116] := Text116;
        Keyword[117] := 'DIMS_SALE';                              Description[117] := Text117;
        Keyword[118] := 'TAX_FREE';                               Description[118] := Text118;
        Keyword[119] := 'SHOP_IN_SHOP';                           Description[119] := Text119;
        Keyword[120] := 'AUDIT_ROLL_VIEW';                        Description[120] := Text120;
        Keyword[121] := 'GOBACK';                                 Description[121] := Text121;
        Keyword[122] := 'GOTOROOT';                               Description[122] := Text122;
        Keyword[123] := 'REPEAT_ENTRY';                           Description[123] := Text123;
        Keyword[124] := 'TERMINAL_PAY';                           Description[124] := Text124;
        Keyword[125] := 'SALESDOC_ASK_ON';                        Description[125] := Text125;
        Keyword[126] := 'SALESDOC_ASK_OFF';                       Description[126] := Text126;
        Keyword[127] := 'SALESDOC_PRINT_ON';                      Description[127] := Text127;
        Keyword[128] := 'SALESDOC_PRINT_OFF';                     Description[128] := Text128;
        Keyword[129] := 'SALESDOC_INVOICE_ON';                    Description[129] := Text129;
        Keyword[130] := 'SALESDOC_INVOICE_OFF';                   Description[130] := Text130;
        Keyword[131] := 'SALESDOC_POST_ON';                       Description[131] := Text131;
        Keyword[132] := 'SALESDOC_POST_OFF';                      Description[132] := Text132;
        Keyword[133] := 'SALESDOC_RECEIVE_ON';                    Description[133] := Text133;
        Keyword[134] := 'SALESDOC_RECEIVE_OFF';                   Description[134] := Text134;
        Keyword[135] := 'SALESDOC_SHIP_ON';                       Description[135] := Text135;
        Keyword[136] := 'SALESDOC_SHIP_OFF';                      Description[136] := Text136;
        Keyword[137] := 'SALESDOC_TYPE_ORD';                      Description[137] := Text137;
        Keyword[138] := 'SALESDOC_TYPE_INV';                      Description[138] := Text138;
        Keyword[139] := 'SALESDOC_TYPE_RET';                      Description[139] := Text139;
        Keyword[140] := 'SALESDOC_TYPE_CRED';                     Description[140] := Text140;
        Keyword[141] := 'SALESDOC_WRITE_AUDIT';                   Description[141] := Text141;
        Keyword[142] := 'SALESDOC_PROCESS';                       Description[142] := Text142;
        Keyword[143] := 'IMPORT_SALESQUOTE';                      Description[143] := Text143;
        Keyword[144] := 'IMPORT_SALESINVOICE';                    Description[144] := Text144;
        Keyword[145] := 'IMPORT_SALESORDER';                      Description[145] := Text145;
        Keyword[146] := 'IMPORT_CREDITMEMO';                      Description[146] := Text146;
        Keyword[147] := 'IMPORT_RETURNORDER';                     Description[147] := Text147;
        //-NPR4.14
        Keyword[148] := 'SALESDOC_CR_MSG';                        Description[148] := Text148;
        Keyword[149] := 'SALESDOC_RET_AMT';                       Description[149] := Text149;
        Keyword[150] := 'COMMIT_TRANSACTION';                     Description[150] := Text150;
        Keyword[151] := 'IMPORT_SO_AMT';                          Description[151] := Text151;
        Keyword[152] := 'SALESDOC_DEPOSIT_DLG';                   Description[152] := Text152;
        Keyword[153] := 'SALESDOC_OUTPUT_DOCUMENT';               Description[153] := Text153;
        Keyword[154] := 'SALESDOC_OPEN_PAGE';                     Description[154] := Text154;
        Keyword[155] := 'SALESDOC_TEST_SALE';                     Description[155] := Text155;
        Keyword[156] := 'SALESDOC_ORD_TYPE';                      Description[156] := Text156;
        Keyword[157] := 'IMPORT_ORD_TYPE';                        Description[157] := Text157;
        //+NPR4.14

        //-MM1.01
        Keyword[158] := 'MM_SCAN_CARD';                           Description[158] := Text158;
        //+MM1.01
        //-#TM1.09
        Keyword[159] := 'TM_SCAN_TICKET';                         Description[159] := Text159;
        //+#TM1.09

        //-NPR5.20
        Keyword[161] := 'TERMINAL_OPENSHIFT';                     Description[161] := Text161;
        Keyword[162] := 'TERMINAL_OPENSHIFT';                     Description[162] := Text162;
        //+NPR5.20
        //-NPR5.22
        Keyword[163] := 'TERMINAL_OFFLINE';                       Description[163] := Text163;
        Keyword[164] := 'TERMINAL_INSTALL';                       Description[164] := Text163;
        //+NPR5.22
        //-NPR5.22
        Keyword[165] := 'CUST_LOCATION_IMPORT';                   Description[165] := Text165;
        Keyword[166] := 'CUST_LOCATION_EXPORT';                   Description[166] := Text166;
        Keyword[167] := 'CUST_LOCATION_PRINT';                    Description[167] := Text167;
        Keyword[168] := 'CUST_LOCATION_LIST';                     Description[168] := Text168;
        //+NPR5.22
        //-NPR5.32 [270885]
        Keyword[169] := 'SALE_INIT_ORDER';                               Description[169] := Text089;
        //+NPR5.32 [270885]
        IsInitialized := true;
    end;

    procedure IsKeyword(Value: Text): Boolean
    var
        TempMetaFunction: Record "Touch Screen - Meta Functions" temporary;
        Index: Integer;
        FoundKeyword: Boolean;
    begin
        Init;
        CreateTempTable(TempMetaFunction);
        //-NPR4.14
        //TempMetaFunction.SETRANGE(Code,Value);
        //EXIT(NOT TempMetaFunction.ISEMPTY);
        FoundKeyword := false;
        if TempMetaFunction.FindSet(false,false) then repeat
          FoundKeyword := StrPos(Value,TempMetaFunction.Code)>0;
        until (TempMetaFunction.Next=0) or FoundKeyword;
        exit(FoundKeyword);
        //+NPR4.14
    end;

    procedure DoLookup(CurrentKeyword: Code[20]) NewKeyword: Code[20]
    var
        TempMetaFunction: Record "Touch Screen - Meta Functions" temporary;
    begin
        Init;

        CreateTempTable(TempMetaFunction);

        TempMetaFunction.SetRange(Code,CurrentKeyword);
        if TempMetaFunction.FindFirst then;
        TempMetaFunction.SetRange(Code);

        if PAGE.RunModal(0,TempMetaFunction)=ACTION::LookupOK then
          NewKeyword := TempMetaFunction.Code
        else
          NewKeyword := CurrentKeyword;

        exit(NewKeyword);
    end;

    procedure CreateTempTable(var TempMetaFunction: Record "Touch Screen - Meta Functions" temporary)
    var
        Language: Record Language;
        MetaFunctionTranslation: Record "Touch Screen - Meta F. Trans";
        MetaFunction: Record "Touch Screen - Meta Functions";
        Index: Integer;
        NextLineNo: Integer;
    begin
        Init;

        TempMetaFunction.Reset;
        TempMetaFunction.DeleteAll;


        Language.SetRange("Windows Language ID", GlobalLanguage);
        if Language.Find('-') then;

        if MetaFunction.FindSet(false,false) then repeat
          if MetaFunction.Code<>'' then begin
            TempMetaFunction.Init;
            TempMetaFunction := MetaFunction;
            if MetaFunctionTranslation.Get(MetaFunction.Code,Language.Code) then
              TempMetaFunction.Description := MetaFunctionTranslation.Description
            else
              TempMetaFunction.Description := '';
            TempMetaFunction.Insert;
            NextLineNo := MetaFunction."No.";
          end;
        until MetaFunction.Next=0;

        NextLineNo += 1;

        for Index:=1 to ArrayLen(Keyword) do begin
          if Keyword[Index]<>'' then begin
            TempMetaFunction.SetRange(Code,Keyword[Index]);
            if TempMetaFunction.IsEmpty then begin
              TempMetaFunction.Init;
              TempMetaFunction.Code := Keyword[Index];
              TempMetaFunction."No." := NextLineNo;
              //-NPR5.30 [265676]
              //TempMetaFunction.Description := Description[Index];
              TempMetaFunction.Description := CopyStr(Description[Index],1,MaxStrLen(TempMetaFunction.Description));
              //+NPR5.30 [265676]
              TempMetaFunction.Insert;
              NextLineNo += 1;
            end;
          end;
        end;

        TempMetaFunction.Reset;
    end;
}

