codeunit 6150822 "POS Action - Conv Touch2Trans"
{
    // 
    // NPR5.37/TSA /20171024 CASE 294214 Discontinuing the POS Menu Button Action Type::ItemGroup - See case for replacement options
    // NPR5.39/MMV /20180209  CASE 299114 Added call to publish any auto updated actions
    // NPR5.40/MHA /20180305  CASE 306461 Added function GetItemIdentifyerType() and adjusted SetActionParameter() for case 306347
    // NPR5.40/VB  /20180307 CASE 306347 Invoking physical action discovery when needed.


    trigger OnRun()
    var
        POSAction: Record "POS Action";
    begin
        LeftMenuGridHeight := GetButtonLeftHeight;
        StartFresh;
        BasicTranscendenceSetup;
        //-NPR5.40 [306347]
        POSAction.DiscoverActions();
        //+NPR5.40 [306347]
        StartConvert;
    end;

    var
        ActionDescription: Label 'Warning: This Action will convert the old Touch screen POS buttons to Transcendence';
        LeftMenuGridHeight: Integer;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('', 'respond();');
            RegisterWorkflow(false);
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Confirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        //-NPR5.40 [306347]
        POSSession.DiscoverActionsOnce();
        //+NPR5.40 [306347]
        StartConvert;

        Handled := true;
    end;

    local procedure ActionCode(): Text
    begin
        exit ('CONV_TOUCH2TRANS');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    local procedure StartConvert()
    var
        TouchScreenMenuLines: Record "Touch Screen - Menu Lines";
    begin
        if Confirm('Convert Login') then begin
          CreateLoginMenu;
          ConvertLeft('SYSTEM_MENU_RIGHT', TouchScreenMenuLines.Type::Login, 2, 6);
        end;

        if Confirm('Convert Submenu - Discount') then
          ConvertLeft('DISCOUNT', TouchScreenMenuLines.Type::Discount, 2, 6);

        if Confirm('Convert Submenu - Print') then
          ConvertLeft('PRINTS', TouchScreenMenuLines.Type::Prints, 2, 6);

        if Confirm('Convert Submenu - Sales Functions') then
          ConvertLeft('MORE_SALE_FUNC', TouchScreenMenuLines.Type::"Sale Functions", 2, 6);

        if Confirm('Convert Submenu - Payment Functions') then
          ConvertLeft('MORE_PAY_FUNC', TouchScreenMenuLines.Type::"Payment Functions", 2, 6);

        if Confirm('Convert Submenu - Customer') then
          ConvertLeft('CUSTOMER', TouchScreenMenuLines.Type::"Customer Functions", 2, 6);

        if Confirm('Convert Submenu - Item') then
          ConvertLeft('FUNCTIONS_ITEM', TouchScreenMenuLines.Type::"Item Functions", 2, 6);

        if Confirm('Convert Sale (Left)') then
          ConvertLeft('SALE-LEFT', TouchScreenMenuLines.Type::"Sale Form", TouchScreenMenuLines."Grid Position"::"Bottom Center",LeftMenuGridHeight);
        if Confirm('Convert Sale (Right)') then
          ConvertRight('SALE-TOP', 'SALE-BOTTOM', TouchScreenMenuLines.Type::"Sale Form", TouchScreenMenuLines."Grid Position"::Right, 0);

        if Confirm('Convert Payment (Left)') then
          ConvertLeft('PAYMENT-LEFT', TouchScreenMenuLines.Type::"Payment Form", TouchScreenMenuLines."Grid Position"::"Bottom Center",LeftMenuGridHeight);
        if Confirm('Convert Payment (Right)') then
          ConvertRight('PAYMENT-TOP', 'PAYMENT-BOTTOM', TouchScreenMenuLines.Type::"Payment Form", TouchScreenMenuLines."Grid Position"::Right, 0);
    end;

    local procedure ConvertLeft(MenuCode: Code[20];TouchScreenType: Integer;GridPosition: Option "Bottom Center",Right,DontCare;GridHeigth: Integer)
    var
        TouchScreenMenuLines: Record "Touch Screen - Menu Lines";
        RegisterTypes: Record "Register Types";
        ParentIDArray: array [20] of Integer;
        NewID: Integer;
    begin
        CheckIsEmpty(MenuCode);
        CreatePOSGroup(MenuCode);

        TouchScreenMenuLines.SetRange(Type, TouchScreenType);
        if GridPosition <> GridPosition::DontCare then
          TouchScreenMenuLines.SetRange("Grid Position", GridPosition);
        if TouchScreenMenuLines.FindSet then begin
          repeat
            if TouchScreenMenuLines.Level = 0 then
              NewID := InsertButtonLine(MenuCode, 0, TouchScreenMenuLines, GridHeigth)
            else
              NewID := InsertButtonLine(MenuCode, ParentIDArray[TouchScreenMenuLines.Level], TouchScreenMenuLines, GridHeigth);
            ParentIDArray[TouchScreenMenuLines.Level + 1] := NewID;
          until TouchScreenMenuLines.Next = 0;
        end;
    end;

    local procedure ConvertRight(MenuCodeCtrl: Code[20];MenuCodeBottom: Code[20];TouchScreenType: Integer;GridPosition: Option "Bottom Center",Right,DontCare;GridHeigth: Integer)
    var
        TouchScreenMenuLines: Record "Touch Screen - Menu Lines";
        RegisterTypes: Record "Register Types";
        ParentIDArray: array [20] of Integer;
        NewID: Integer;
        MenuCode: Code[20];
        TMPXPos: Integer;
        POSMenuButton: Record "POS Menu Button";
    begin
        CheckIsEmpty(MenuCodeBottom);
        CreatePOSGroup(MenuCodeBottom);
        CheckIsEmpty(MenuCodeCtrl);
        CreatePOSGroup(MenuCodeCtrl);

        TouchScreenMenuLines.SetRange(Type, TouchScreenType);
        if GridPosition <> GridPosition::DontCare then
          TouchScreenMenuLines.SetRange("Grid Position", GridPosition);
        if TouchScreenMenuLines.FindSet then repeat
          if TouchScreenMenuLines."Placement ID" <= 6 then begin
            GridHeigth := 3;
            MenuCode := MenuCodeCtrl;
          end else begin
            GridHeigth := 3;
            MenuCode := MenuCodeBottom;
          end;

          if TouchScreenMenuLines.Level = 0 then
            NewID := InsertButtonLine(MenuCode, 0, TouchScreenMenuLines, GridHeigth)
          else
            NewID := InsertButtonLine(MenuCode, ParentIDArray[TouchScreenMenuLines.Level], TouchScreenMenuLines, GridHeigth);
          ParentIDArray[TouchScreenMenuLines.Level + 1] := NewID;
        until TouchScreenMenuLines.Next = 0;

        //grid is fucked up, so it needs to be reshuffeled
        POSMenuButton.SetRange("Menu Code", MenuCodeCtrl);
        if POSMenuButton.FindSet then repeat
          TMPXPos := POSMenuButton."Position X";
          POSMenuButton."Position X" := POSMenuButton."Position Y";
          POSMenuButton."Position Y" := TMPXPos;
          POSMenuButton.Modify;
        until POSMenuButton.Next = 0;

        POSMenuButton.SetRange("Menu Code", MenuCodeBottom);
        if POSMenuButton.FindSet then repeat
          TMPXPos := POSMenuButton."Position X" - 2;
          POSMenuButton."Position X" := POSMenuButton."Position Y";
          POSMenuButton."Position Y" := TMPXPos;
          POSMenuButton.Modify;
        until POSMenuButton.Next = 0;
    end;

    local procedure CheckIsEmpty(MenuCode: Code[20]) IsEmpty: Boolean
    var
        POSMenuButton: Record "POS Menu Button";
        POSMenu: Record "POS Menu";
    begin
        POSMenuButton.SetRange("Menu Code", MenuCode);
        if POSMenuButton.IsEmpty then
          exit(true);

        if not Confirm('Warning: Menu %1 is not empty. Do you wish to delete the current menu content?', true, MenuCode) then
          exit(false);

        POSMenuButton.DeleteAll;
        exit(true);
    end;

    local procedure InsertButtonLine(MenuCode: Code[20];ParentID: Integer;TSMenuLines: Record "Touch Screen - Menu Lines";GridHeigth: Integer) NewID: Integer
    var
        POSMenuButton: Record "POS Menu Button";
        Item: Record Item;
        ItemGroup: Record "Item Group";
        POSActionParameter: Record "POS Action Parameter";
        POSParameterValue: Record "POS Parameter Value";
        PaymentTypePOS: Record "Payment Type POS";
        Customer: Record Customer;
        PrevRec: Text;
    begin
        if TSMenuLines."Filter No." = 'GOBACK' then
          exit;
        POSMenuButton.Init;
        POSMenuButton.Validate("Menu Code", MenuCode);
        POSMenuButton.Validate("Parent ID", ParentID);
        POSMenuButton.Insert(true);

        POSMenuButton.Validate(Level, TSMenuLines.Level);
        POSMenuButton.Caption := TSMenuLines."Text Line 1";
        POSMenuButton.Tooltip := TSMenuLines.Description;
        //temporary fix - must be enabled again
        POSMenuButton."Register Type" := TSMenuLines."Register Type"; //-NPR5.38 [297943] (enabled again)
        if StrLen(TSMenuLines.Terminal) > 10 then begin
          POSMenuButton."Register No." := 'x';
          POSMenuButton."Background Image Url" := TSMenuLines.Terminal;
        end else
          POSMenuButton."Register No." := TSMenuLines.Terminal;
        POSMenuButton."Salesperson Code" := TSMenuLines."Only Visible To";

        case TSMenuLines."Line Type" of
          TSMenuLines."Line Type"::Customer:
            begin
              if Customer.Get(TSMenuLines."Filter No.") then begin
                POSMenuButton.Validate("Action Type", POSMenuButton."Action Type"::Action);
                POSMenuButton.Validate("Action Code", 'Receivables');
                POSMenuButton.Modify(true);
                SetActionParameter(POSMenuButton, 'customerNo', TSMenuLines."Filter No.", false);
              end;
            end;
          TSMenuLines."Line Type"::Item:
            begin
              if TSMenuLines.Type in [TSMenuLines.Type::"Payment Form", TSMenuLines.Type::"Payment Functions", TSMenuLines.Type::PaymentType] then begin
                if PaymentTypePOS.Get(TSMenuLines."Filter No.") then begin
                  SetPaymentType(POSMenuButton, TSMenuLines."Filter No.");
                end;
              //-NPR5.40 [306461]
              //END ELSE BEGIN
              //  IF Item.GET(TSMenuLines."Filter No.") THEN BEGIN
              //    //-NPR5.38 [297943]
              //    //POSMenuButton.VALIDATE("Action Type", POSMenuButton."Action Type"::Item);
              //    //POSMenuButton.VALIDATE("Action Code", TSMenuLines."Filter No.");
              //    POSMenuButton.VALIDATE("Action Type", POSMenuButton."Action Type"::Action);
              //    POSMenuButton.VALIDATE("Action Code", 'ITEM');
              //    POSMenuButton.MODIFY(TRUE);
              //    SetActionParameter(POSMenuButton, 'itemNo', TSMenuLines."Filter No.", FALSE);
              //    //+NPR5.38 [297943]
              //  END;
              //END;
              end else if TSMenuLines."Filter No." <> '' then begin
                POSMenuButton.Validate("Action Type",POSMenuButton."Action Type"::Action);
                POSMenuButton.Validate("Action Code",'ITEM');
                POSMenuButton.Modify(true);
                SetActionParameter(POSMenuButton,'itemNo',TSMenuLines."Filter No.",false);
                SetActionParameter(POSMenuButton,'itemIdentifyerType',GetItemIdentifyerType(TSMenuLines."Filter No."),false);
              end;
              //+NPR5.40 [306461]
            end;
          //-NPR5.38 [297943]
          TSMenuLines."Line Type"::"Item Group":
            begin
              if TSMenuLines."Filter No." <> '' then
                POSMenuButton.Blocked := true;
            end;
          //+NPR5.38 [297943]

          //-NPR5.37 [294214]
        //  TSMenuLines."Line Type"::"Item Group":
        //    BEGIN
        //      IF ItemGroup.GET(TSMenuLines."Filter No.") THEN BEGIN
        //        POSMenuButton.VALIDATE("Action Type", POSMenuButton."Action Type"::ItemGroup);
        //        POSMenuButton.VALIDATE("Action Code", TSMenuLines."Filter No.");
        //      END;
        //    END;
          //+NPR5.37 [294214]

          TSMenuLines."Line Type"::Page:
            begin
              POSMenuButton.Validate("Action Type", POSMenuButton."Action Type"::Action);
              POSMenuButton.Validate("Action Code", 'RUNPAGE');
              POSMenuButton.Modify(true);
              SetActionParameter(POSMenuButton, 'PAGEID', TSMenuLines."Filter No.", false);
            end;
          TSMenuLines."Line Type"::Report:
            begin
              POSMenuButton.Validate("Action Type", POSMenuButton."Action Type"::Action);
              POSMenuButton.Validate("Action Code", 'RUNREPORT');
              POSMenuButton.Modify(true);
              POSActionParameter.SetRange("POS Action Code", POSMenuButton."Action Code");
              if POSActionParameter.FindSet then repeat
                //-NPR5.40 [306461]
                // TMPPOSParameterValue."Action Code" := POSActionParameter."POS Action Code";
                // TMPPOSParameterValue.Name := POSActionParameter.Name;
                // TMPPOSParameterValue."Data Type" := POSActionParameter."Data Type";
                // TMPPOSParameterValue.Value := POSActionParameter."Default Value";
                // IF UPPERCASE (TMPPOSParameterValue.Name) = 'REPORTID' THEN
                //  TMPPOSParameterValue.Value := TSMenuLines."Filter No.";
                // TMPPOSParameterValue.INSERT;
                POSParameterValue.SetRange("Table No.",DATABASE::"POS Menu Button");
                POSParameterValue.SetRange(Code,POSMenuButton."Menu Code");
                POSParameterValue.SetRange(ID,POSMenuButton.ID);
                POSParameterValue.SetRange(Name,POSActionParameter.Name);
                if not POSParameterValue.FindFirst then begin
                  POSParameterValue.Init;
                  POSParameterValue."Table No." := DATABASE::"POS Menu Button";
                  POSParameterValue.Code := POSMenuButton."Menu Code";
                  POSParameterValue.ID := POSMenuButton.ID;
                  POSParameterValue.Name := POSActionParameter.Name;
                  POSParameterValue.Insert
                end;

                PrevRec := Format(POSParameterValue);

                POSParameterValue."Action Code" := POSActionParameter."POS Action Code";
                POSParameterValue."Data Type" := POSActionParameter."Data Type";
                POSParameterValue.Value := POSActionParameter."Default Value";
                if UpperCase (POSParameterValue.Name) = 'REPORTID' then
                  POSParameterValue.Value := TSMenuLines."Filter No.";

                if PrevRec <> Format(POSParameterValue) then
                  POSParameterValue.Modify;
                //+NPR5.40 [306461]
              until POSActionParameter.Next = 0;
              //-NPR5.40 [306461]
              // RRPef.SETTABLE(POSMenuButton);
              //+NPR5.40 [306461]
            end;
          TSMenuLines."Line Type"::Internal:
            begin
              InternalFunctionTranslate(TSMenuLines,POSMenuButton);
            end;
          else
            begin
              POSMenuButton.Blocked := true;
            end;
        end;

        //new: default,green,red,dark-red,gray,purple,indigo,yellow,orange,white
        //old: '',Green,Red,Dark Red,Grey,Purple,Indigo,Yellow,Orange,White
        case TSMenuLines."Button Styling" of
          TSMenuLines."Button Styling"::Green:      POSMenuButton."Background Color" := 'green';
          TSMenuLines."Button Styling"::Red:        POSMenuButton."Background Color" := 'red';
          TSMenuLines."Button Styling"::"Dark Red": POSMenuButton."Background Color" := 'dark-red';
          TSMenuLines."Button Styling"::Grey:       POSMenuButton."Background Color" := 'gray';
          TSMenuLines."Button Styling"::Purple:     POSMenuButton."Background Color" := 'purple';
          TSMenuLines."Button Styling"::Indigo:     POSMenuButton."Background Color" := 'indigo';
          TSMenuLines."Button Styling"::Yellow:     POSMenuButton."Background Color" := 'yellow';
          TSMenuLines."Button Styling"::Orange:     POSMenuButton."Background Color" := 'orange';
          TSMenuLines."Button Styling"::White:      POSMenuButton."Background Color" := 'white';
        end;

        POSMenuButton."Icon Class" := TSMenuLines."Icon Class";

        //-NPR5.38 [297943]
        if not TSMenuLines.Visible then begin
          POSMenuButton.Blocked := true;
          POSMenuButton."Custom Class Attribute" := 'Not Visible';
        end;
        //+NPR5.38 [297943]

        POSMenuButton."Position X" := ((TSMenuLines."Placement ID" - 1) div GridHeigth) + 1;
        POSMenuButton."Position Y" := ((TSMenuLines."Placement ID" - 1) mod GridHeigth) + 1;

        POSMenuButton.Modify(true);
        exit(POSMenuButton.ID);
    end;

    local procedure CreatePOSGroup(MenuCode: Code[20])
    var
        POSMenu: Record "POS Menu";
    begin
        POSMenu.Init;
        POSMenu.Code := MenuCode;

        POSMenu.Description := 'Converted Menu';
        if not POSMenu.Insert then
          POSMenu.Modify;
    end;

    local procedure InternalFunctionTranslate(TSMenuLines: Record "Touch Screen - Menu Lines";var POSMenuButton: Record "POS Menu Button")
    var
        FirstParameter: Text;
        LastParameter: Text;
        SplitPos: Integer;
        PaymentTypePOS: Record "Payment Type POS";
    begin
        case TSMenuLines."Filter No." of
          //Popup Menus
          'FUNCTIONS_DISCOUNT': SetPopupMenu(POSMenuButton, 'DISCOUNT');
          'PRINTS':             SetPopupMenu(POSMenuButton, 'PRINTS');
          'CUSTOMER':           SetPopupMenu(POSMenuButton, 'CUSTOMER');
          'FUNCTIONS_ITEM':     SetPopupMenu(POSMenuButton, 'ITEMS'); //ITEMFUNCTIONS

          'SALE-TOP':         SetPopupMenu(POSMenuButton, 'SALE-TOP');
          'FUNCTIONS_SALE':   SetPopupMenu(POSMenuButton, 'MORE_SALE_FUNC');
          'RETURN':           SetPopupMenu(POSMenuButton, 'RETURN');
          'STATISTICS':       SetPopupMenu(POSMenuButton, 'STATISTICS');
          'DISCOUNT SCHEMES': SetPopupMenu(POSMenuButton, 'DISCOUNT_SCHEMES');
          'SALE-BOTTOM':      SetPopupMenu(POSMenuButton, 'SALE-BOTTOM');

          //Payment Types
          'TERMINAL_PAY' :        SetPaymentType(POSMenuButton, 'T');
          //-NPR5.38 [297943]
          //'ENTERPUSH' :           SetPaymentType(POSMenuButton, 'K');
          'ENTERPUSH' :
            begin
              PaymentTypePOS.SetRange("Processing Type", PaymentTypePOS."Processing Type"::Cash);
              if PaymentTypePOS.Count > 1 then
                PaymentTypePOS.SetFilter("No.", '@K*');
              PaymentTypePOS.FindFirst;
              SetPaymentType(POSMenuButton, PaymentTypePOS."No.");
            end;
          //+NPR5.38 [297943]

          //Simple Actions
          'DELETE_LINE':          SetSimpleLineAction(POSMenuButton, 'DELETE_POS_LINE');
          'CANCEL_SALE':          SetSimpleLineAction(POSMenuButton, 'CANCEL_POS_SALE');
          'Zoom Sales Line':      SetSimpleLineAction(POSMenuButton, 'ZOOM');
          'COMMENT_INSERT':       SetSimpleLineAction(POSMenuButton, 'INSERT_COMMENT');
          'REGISTER_CHANGE':      SetSimpleLineAction(POSMenuButton, 'SWITCH_REGISTER');
          'BALANCE_REGISTER':     SetSimpleLineAction(POSMenuButton, 'BALANCE_V1');
          'SALE_REVERSE':         SetSimpleLineAction(POSMenuButton, 'REVERSE_SALE');
          'CREDITVOUCHER_CREATE': SetSimpleLineAction(POSMenuButton, 'CREDIT_GIFTVOUCHER');
          'CREDITVOUCHER_CREATE': SetSimpleLineAction(POSMenuButton, 'QUANTITY');
          'REGISTER_OPEN' :       SetSimpleLineAction(POSMenuButton, 'OPEN_CASH_DRAWER');


          //Complex Actions
          'LINE_AMOUNT' :               SetComplexLineAction(POSMenuButton, 'DISCOUNT', 'DiscountType', 'LineAmount', false);
          'LINE_DISCOUNT_AMOUNT' :      SetComplexLineAction(POSMenuButton, 'DISCOUNT', 'DiscountType', 'LineDiscountAmount', false);
          'LINE_DISCOUNTPCT_ABS' :      SetComplexLineAction(POSMenuButton, 'DISCOUNT', 'DiscountType', 'LineDiscountPercentABS', false);
          'LINE_DISCOUNTPCT_REL' :      SetComplexLineAction(POSMenuButton, 'DISCOUNT', 'DiscountType', 'LineDiscountPercentREL', false);
          'LINE_UNITPRICE' :            SetComplexLineAction(POSMenuButton, 'DISCOUNT', 'DiscountType', 'LineUnitPrice', false);
          'TOTAL_AMOUNT' :              SetComplexLineAction(POSMenuButton, 'DISCOUNT', 'DiscountType', 'TotalAmount', false);
          'TOTAL_DISCOUNT' :            SetComplexLineAction(POSMenuButton, 'DISCOUNT', 'DiscountType', 'TotalDiscountAmount', false);
          'TOTAL_DISCOUNTPCT_ABS' :     SetComplexLineAction(POSMenuButton, 'DISCOUNT', 'DiscountType', 'DiscountPercentABS', false);
          'TOTAL_DISCOUNTPCT_REL' :     SetComplexLineAction(POSMenuButton, 'DISCOUNT', 'DiscountType', 'DiscountPercentREL', false);
          'NPORDER_GET' :               SetComplexLineAction(POSMenuButton, 'CUSTOMERINFO','CustomerType','NPOrderGet', false);
          'NPORDER_SEND' :              SetComplexLineAction(POSMenuButton, 'CUSTOMERINFO','CustomerType','NPOrderSend', false);
          'OUT_PAYMENT' :               SetComplexLineAction(POSMenuButton, 'PAYIN_PAYOUT','Pay Option','Payout', false);
          'SEND_TO_ORDER / SALESORDER': SetComplexLineAction(POSMenuButton, 'CREATE_SALESORDER','InitNewSaleOnDone','SAND', false);
          'CUSTOMER REPAIR' :           SetComplexLineAction(POSMenuButton, 'CUSTOMERINFO','CustomerType','RepairSend', false);
          'REGISTER_LOCK' :             SetComplexLineAction(POSMenuButton, 'CHANGE_VIEW','ViewType','Locked', false);
          'SALE_GIFTVOUCHER' :          SetComplexLineAction(POSMenuButton, 'SALE_GIFTVOUCHER','DiscountType','Amount', false);
          'TURNOVER_REPORT' :           SetComplexLineAction(POSMenuButton, 'SALES_STATISTICS','Statistic Type','Statistics', false);
          'TURNOVER_SALE' :             SetComplexLineAction(POSMenuButton, 'SALES_STATISTICS','Statistic Type','Sale', false);
          'TURNOVER_STATS' :            SetComplexLineAction(POSMenuButton, 'SALES_STATISTICS','Statistic Type','Report', false);
          'GOTO_PAYMENT' :              SetComplexLineAction(POSMenuButton, 'CHANGE_VIEW','ViewType','Payment', false);
          //'CUSTOMER_CRM' :              SetComplexLineAction(POSMenuButton, '','Type','CustomerCRM', false);
          'CUSTOMER_ILE' :              SetComplexLineAction(POSMenuButton, 'CUSTOMERINFO','Type','CustomerILE', false);
          'CUSTOMER_INFO' :             SetComplexLineAction(POSMenuButton, 'CUSTOMERINFO','Type','CustomerInfo', false);
          'CUSTOMER_PAY' :              SetComplexLineAction(POSMenuButton, 'RECEIVABLES','Type','InvoiceCustomer', false);
          'INSERT_PAYMENT' :            SetComplexLineAction(POSMenuButton, 'RECEIVABLES','Type','ApplyPaymentToInvoices', false);
          'INSERT_PAYMENT_CASH' :       SetComplexLineAction(POSMenuButton, 'RECEIVABLES','Type','DepositAmount', false);
          'DEBIT_INFO' :                SetComplexLineAction(POSMenuButton, 'CUSTOMERINFO','Type','DebitInfo', false);
          'PRINT_EXCHLABEL_ALL' :       SetComplexLineAction(POSMenuButton, 'PRINT_EXCH_LABEL','Setting','All Lines', false);
          'PRINT_EXCHLABEL_LINE_ALL' :  SetComplexLineAction(POSMenuButton, 'PRINT_EXCH_LABEL','Setting','Line Quantity', false);
          'PRINT_EXCHLABEL_LINE_ONE' :  SetComplexLineAction(POSMenuButton, 'PRINT_EXCH_LABEL','Setting','Single', false);
          'PRINT_EXCHLABEL_PACKAGE' :   SetComplexLineAction(POSMenuButton, 'PRINT_EXCH_LABEL','Setting','Package', false);
          'PRINT_ITEM_LABEL' :          SetComplexLineAction(POSMenuButton, 'PRINT_ITEM','PrintType','Price', false);
          'PRINT_LAST_RECEIPT' :        SetComplexLineAction(POSMenuButton, 'PRINT_RECEIPT','Setting','Last Receipt', false);
          'PRINT_LAST_RECEIPT_A4' :     SetComplexLineAction(POSMenuButton, 'PRINT_RECEIPT','Setting','Last Receipt Large', false);
          'TERMINAL_OPENSHIFT' :        SetComplexLineAction(POSMenuButton, 'XXX_TERMINAL','auxCommand','Ticket Reprint', false);
          'TERMINAL_ENDOFDAY' :         SetComplexLineAction(POSMenuButton, 'XXX_TERMINAL','auxCommand','Ticket Reprint', false);
          'Reprint' :                   SetComplexLineAction(POSMenuButton, 'XXX_TERMINAL','auxCommand','Ticket Reprint', false);
          'TERMINAL_AUX' :              SetComplexLineAction(POSMenuButton, 'XXX_TERMINAL','auxCommand','StrMenu', false);
          'TERMINAL_INSTALL' :          SetComplexLineAction(POSMenuButton, 'XXX_TERMINAL','auxCommand','Ticket Reprint', false);
          'TERMINAL_CANCEL' :           SetComplexLineAction(POSMenuButton, 'XXX_TERMINAL','auxCommand','StrMenu', false);
          'TERMINAL_OFFLINE' :          SetComplexLineAction(POSMenuButton, 'XXX_TERMINAL','auxCommand','StrMenu', false);
          'TAX_FREE' :                  SetComplexLineAction(POSMenuButton, 'TAX_FREE','Setting','Toggle', false);
          'Audit Roll View' :           SetComplexLineAction(POSMenuButton, '','PageId','6014432', false);
          'TERMINAL_INSTALL' :          SetComplexLineAction(POSMenuButton, 'XXX_TERMINAL','auxCommand','Ticket Reprint', false);
          'GOTO_SALE' :                 SetComplexLineAction(POSMenuButton, 'CHANGE_VIEW','ViewType','Sale', false);
          'QUANTITY_POS' :              SetComplexLineAction(POSMenuButton, 'Quantity', 'Constraint', 'Positive Quantity Only', false);
          'QUANTITY_NEG' :              SetComplexLineAction(POSMenuButton, 'Quantity', 'Constraint', 'No Constraint', false); //JDH
          'GET_SAVED_SALE' :            SetComplexLineAction(POSMenuButton, 'PARK_SALE', 'Function', 'Retrieve Parked Sale', false);
          'GET_SALE' :                  SetComplexLineAction(POSMenuButton, 'PARK_SALE', 'Function', 'Retrieve Parked Sale', false);
          'SALE_SAVE' :                 SetComplexLineAction(POSMenuButton, 'PARK_SALE', 'Function', 'Park Sale', false);
          'LOOKUP' :                    SetComplexLineAction(POSMenuButton, 'LOOKUP', 'LookupType', 'Item', false);
          'CUSTOMER_STD' :              SetComplexLineAction(POSMenuButton, 'CUSTOMERINFO','CustomerType','CustomerSTD', false);
          'TM_SCAN_TICKET' :
            begin
              SplitPos := StrPos(TSMenuLines.Parametre, '::');
              if SplitPos <> 0 then begin
                FirstParameter := CopyStr(TSMenuLines.Parametre, 1, SplitPos - 1);
                LastParameter := CopyStr(TSMenuLines.Parametre, SplitPos + 1);
              end else begin
                FirstParameter := TSMenuLines.Parametre;
                LastParameter := '';
              end;

              case FirstParameter of
                'ADMITTED_COUNT' :      SetComplexLineAction(POSMenuButton, 'TM_TICKETMGMT', 'Function', 'Admission Count', false);
                'ARRIVAL' :             SetComplexLineAction(POSMenuButton, 'TM_TICKETMGMT', 'Function', 'Register Arrival', true);
              end;
            end;
          'MM_SCAN_CARD' :
            begin
              case TSMenuLines.Parametre of
                'SET_MEMBERNUMBER' :    SetComplexLineAction(POSMenuButton, 'MM_MEMBERMGT', 'Function', 'Select Membership', false);
                'MEMBER_ARRIVAL' :      SetSimpleLineAction(POSMenuButton, 'MM_MEMBER_ARRIVAL');
                //'EDIT_MEMBERINFO' :
                'RENEW_MEMBERSHIP' :    SetComplexLineAction(POSMenuButton, 'MM_MEMBERMGT', 'Function', 'Renew Membership', false);
                'UPGRADE_MEMBERSHIP' :  SetComplexLineAction(POSMenuButton, 'MM_MEMBERMGT', 'Function', 'Upgrade Membership', false);
              end;
            end;




          else begin
            POSMenuButton.Blocked := true;
            POSMenuButton.Enabled := POSMenuButton.Enabled::No;
          end;
        end;
    end;

    local procedure SetPopupMenu(var POSMenuButton: Record "POS Menu Button";NewMenu: Code[20])
    var
        POSMenu: Record "POS Menu";
    begin
        if not POSMenu.Get(NewMenu) then
          CreatePOSGroup(NewMenu);
        POSMenuButton.Validate("Action Type", POSMenuButton."Action Type"::PopupMenu);
        POSMenuButton.Validate("Action Code", NewMenu);
    end;

    local procedure SetSimpleLineAction(var POSMenuButton: Record "POS Menu Button";NewAction: Code[20])
    begin
        POSMenuButton.Validate("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.Validate("Action Code", NewAction);
    end;

    local procedure SetComplexLineAction(var POSMenuButton: Record "POS Menu Button";NewAction: Code[20];ParameterName: Text[30];ParameterValue: Text;InValidateButton: Boolean)
    var
        POSAction: Record "POS Action";
    begin
        if POSAction.Get(NewAction) then begin
          POSMenuButton.Validate("Action Type", POSMenuButton."Action Type"::Action);
          POSMenuButton.Validate("Action Code", NewAction);
          SetActionParameter(POSMenuButton, ParameterName, ParameterValue, InValidateButton);
        end;
    end;

    local procedure SetActionParameter(var PosMenuButton: Record "POS Menu Button";ParameterName: Text[30];ParameterValue: Text;InValidateButton: Boolean)
    var
        POSActionParameter: Record "POS Action Parameter";
        POSParameterValue: Record "POS Parameter Value";
        PrevRec: Text;
        RecordID: RecordID;
    begin
        //-NPR5.40 [306461]
        // POSActionParameter.SETRANGE("POS Action Code", PosMenuButton."Action Code");
        // IF POSActionParameter.FINDSET THEN REPEAT
        //  TMPPOSParameterValue."Action Code" := POSActionParameter."POS Action Code";
        //  TMPPOSParameterValue.Name := POSActionParameter.Name;
        //  TMPPOSParameterValue."Data Type" := POSActionParameter."Data Type";
        //  TMPPOSParameterValue.Value := POSActionParameter."Default Value";
        //  IF UPPERCASE (TMPPOSParameterValue.Name) = UPPERCASE(ParameterName) THEN
        //    TMPPOSParameterValue.Value := ParameterValue;
        //  IF NOT ((ParameterName = TMPPOSParameterValue.Name) AND (ParameterName <> '') AND (ParameterValue = '')) THEN
        //    TMPPOSParameterValue.INSERT;
        // UNTIL POSActionParameter.NEXT = 0;
        // IF InValidateButton THEN BEGIN
        //  TMPPOSParameterValue."Action Code" := PosMenuButton."Action Code";
        //  TMPPOSParameterValue.Name := 'InvalidateButton';
        //  TMPPOSParameterValue."Data Type" := TMPPOSParameterValue."Data Type"::Boolean;
        //  TMPPOSParameterValue.Value := 'true';
        //  TMPPOSParameterValue.INSERT;
        // END;
        // RRef.GETTABLE(PosMenuButton);
        // FRef := RRef.FIELD(PosMenuButton.FIELDNO(PosMenuButton.Parameters));
        // POSActionParameterMgt.SaveToField(TMPPOSParameterValue, FRef);
        // RRef.SETTABLE(PosMenuButton);
        POSActionParameter.SetRange("POS Action Code",PosMenuButton."Action Code");
        if POSActionParameter.FindSet then
          repeat
            POSParameterValue.SetRange("Table No.",DATABASE::"POS Menu Button");
            POSParameterValue.SetRange(Code,PosMenuButton."Menu Code");
            POSParameterValue.SetRange(ID,PosMenuButton.ID);
            POSParameterValue.SetRange(Name,POSActionParameter.Name);
            if not POSParameterValue.FindFirst then begin
              POSParameterValue.Init;
              POSParameterValue."Table No." := DATABASE::"POS Menu Button";
              POSParameterValue.Code := PosMenuButton."Menu Code";
              POSParameterValue.ID := PosMenuButton.ID;
              POSParameterValue.Name := POSActionParameter.Name;
              POSParameterValue."Action Code" := POSActionParameter."POS Action Code";
              POSParameterValue."Data Type" := POSActionParameter."Data Type";
              POSParameterValue.Value := POSActionParameter."Default Value";
              POSParameterValue.Insert;
            end;
            PrevRec := Format(POSParameterValue);

            if UpperCase(POSParameterValue.Name) = UpperCase(ParameterName) then
              POSParameterValue.Value := ParameterValue;

            if PrevRec <> Format(POSParameterValue) then
              POSParameterValue.Modify;
          until POSActionParameter.Next = 0;
        if InValidateButton then begin
          POSParameterValue.SetRange("Table No.",DATABASE::"POS Menu Button");
          POSParameterValue.SetRange(Code,PosMenuButton."Menu Code");
          POSParameterValue.SetRange(ID,PosMenuButton.ID);
          POSParameterValue.SetRange(Name,'InvalidateButton');

          if not POSParameterValue.FindFirst then begin
            POSParameterValue.Init;
            POSParameterValue."Table No." := DATABASE::"POS Menu Button";
            POSParameterValue.Code := PosMenuButton."Menu Code";
            POSParameterValue.ID := PosMenuButton.ID;
            POSParameterValue.Name := 'InvalidateButton';
            POSParameterValue.Insert;
          end;
          PrevRec := Format(POSParameterValue);
          POSParameterValue."Action Code" := PosMenuButton."Action Code";
          POSParameterValue."Data Type" := POSParameterValue."Data Type"::Boolean;
          POSParameterValue.Value := 'true';

          if PrevRec <> Format(POSParameterValue) then
              POSParameterValue.Modify;
        end;
        //+NPR5.40 [306461]
    end;

    local procedure SetPaymentType(var POSMenuButton: Record "POS Menu Button";NewAction: Code[20])
    begin
        POSMenuButton.Validate("Action Type", POSMenuButton."Action Type"::PaymentType);
        POSMenuButton.Validate("Action Code", NewAction);
    end;

    local procedure BasicTranscendenceSetup()
    var
        POSView: Record "POS View";
        POSSetup: Record "POS Setup";
        CodeunitInstanceDetector: Codeunit "POS Action Management";
        POSAction: Record "POS Action";
    begin
        if POSView.IsEmpty then begin
          POSView.Init;
          POSView.Code := 'LOGIN';
          POSView.Description := 'Login View';
          POSView.Insert;

          POSView.Init;
          POSView.Code := 'SALE-FULL';
          POSView.Description := 'Sale View';
          POSView.Insert;
        end;

        if POSAction.IsEmpty then begin
          CodeunitInstanceDetector.InitializeActionDiscovery();
          BindSubscription(CodeunitInstanceDetector);
          //-NPR5.39 [299114]
          POSAction.DiscoverActions();
          //POSAction.OnDiscoverActions();
          //+NPR5.39 [299114]
        end;

        if not POSSetup.Get then
          POSSetup.Insert;

        if POSSetup."Login Action Code" = '' then
          POSSetup.Validate("Login Action Code", 'LOGIN');

        if POSSetup."Text Enter Action Code" = '' then
          POSSetup.Validate("Text Enter Action Code", 'TEXT_ENTER');

        if POSSetup."Item Insert Action Code" = '' then
          POSSetup.Validate("Item Insert Action Code", 'ITEM');

        if POSSetup."Payment Action Code" = '' then
          POSSetup.Validate("Payment Action Code", 'PAYMENT');

        if POSSetup."Customer Action Code" = '' then
          POSSetup.Validate("Customer Action Code", 'CUST_DEBITSALE');

        POSSetup.Modify;
    end;

    local procedure CreateLoginMenu()
    var
        POSMenu: Record "POS Menu";
        POSMenuButton: Record "POS Menu Button";
    begin
        if POSMenu.Get('LOGIN') then
          exit;

        CreatePOSGroup('LOGIN');
        CreatePOSGroup('SYSTEM_MENU_LEFT');
        CreatePOSGroup('SYSTEM_MENU_RIGHT');

        Clear(POSMenuButton);
        POSMenuButton.Init;
        POSMenuButton.Validate("Menu Code", 'LOGIN');
        POSMenuButton.Validate("Parent ID", 0);
        POSMenuButton.Insert(true);
        POSMenuButton.Validate(Level, 0);
        POSMenuButton.Caption := 'System Menu';
        POSMenuButton.Tooltip := '';
        POSMenuButton."Action Type" := POSMenuButton."Action Type"::PopupMenu;
        POSMenuButton."Action Code" := 'SYSTEM_MENU_LEFT';
        POSMenuButton.Enabled := POSMenuButton.Enabled::Yes;
        POSMenuButton.Modify;

        Clear(POSMenuButton);
        POSMenuButton.Init;
        POSMenuButton.Validate("Menu Code", 'LOGIN');
        POSMenuButton.Validate("Parent ID", 0);
        POSMenuButton.Insert(true);
        POSMenuButton.Validate(Level, 0);
        POSMenuButton.Caption := 'Function';
        POSMenuButton.Tooltip := '';
        POSMenuButton."Action Type" := POSMenuButton."Action Type"::PopupMenu;
        POSMenuButton."Action Code" := 'SYSTEM_MENU_RIGHT';
        POSMenuButton.Enabled := POSMenuButton.Enabled::Yes;
        POSMenuButton.Modify;
    end;

    local procedure StartFresh()
    var
        POSMenu: Record "POS Menu";
        POSMenuButton: Record "POS Menu Button";
    begin
        if not Confirm('Do you want to start fresh on the Transcendense POS setup Conversion\IT WILL DELETE ALL POS MENUS AND POS MENU LINES') then
          exit;

        POSMenu.DeleteAll;
        POSMenuButton.DeleteAll;
    end;

    local procedure GetButtonLeftHeight(): Integer
    var
        TouchScreenLayout: Record "Touch Screen - Layout";
    begin
        case TouchScreenLayout.Count of
          0: exit(5);
          1:
            begin
              TouchScreenLayout.FindFirst;
              exit(TouchScreenLayout."Button Count Vertical");
            end;
          else
            begin
              if PAGE.RunModal(0, TouchScreenLayout) = ACTION::LookupOK then begin
                exit(TouchScreenLayout."Button Count Vertical");
              end else
                Error('you need to select 1 of the TouchScreenLayouts to get the number of buttons from');
            end;
        end;
    end;

    local procedure GetItemIdentifyerType(ItemReferenceNo: Text): Text
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
    begin
        //-NPR5.40 [306461]
        if ItemReferenceNo = '' then
          exit('ItemNo');

        if StrLen(ItemReferenceNo) <= MaxStrLen(ItemCrossReference."Cross-Reference No.") then begin
          ItemCrossReference.SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
          ItemCrossReference.SetRange("Cross-Reference No.",ItemReferenceNo);
          if ItemCrossReference.FindFirst then
            exit('ItemCrossReference');
        end;

        if StrLen(ItemReferenceNo) <= MaxStrLen(Item."No.") then begin
          if Item.Get(UpperCase(ItemReferenceNo)) then
            exit('ItemNo');
        end;

        exit('ItemSearch');
        //+NPR5.40 [306461]
    end;
}

