codeunit 6014620 "POS Web UI Management"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.11/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client - additional changes
    // NPR4.12/VB/20150703 CASE 213003 Fixed text captions with typos
    // NPR4.14/VB/20150909 CASE 222539 Show Behavior for buttons implemented
    // NPR4.14/VB/20150909 CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.14/VB/20150925 CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.14/VB/20151001 CASE 224232 Number formatting
    // NPR4.15/VB/20150930 CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.15/VB/20151002 CASE 224403 Payment methods button text added
    // NPR9   /VB/20150104 CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.20/VB/20151221 CASE 229508 Support for passing number format specifics to JavaScript
    // NPR5.20/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00/NPKNAV/20160113  CASE 229508 NP Retail 2016
    // NPR5.00.03/VB/20160114 CASE 231811 Fixed issue with parsing empty strings to decimals/integers. Empty strings are treated as 0.
    // NPR5.00.03/VB/20160202  CASE 233204 Lookup template for customer table
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.01/VB/20160201 CASE 224334 Several functions made global
    // NPR5.20/VB/20160301 CASE 235863 Filtering by salesperson fixed.
    // NPR5.20/VB/20160307 CASE 235306 Added new text constants
    // NPR5.20/VB/20160310 CASE 236519 Added support for configurable lookup templates.
    // NPR5.22/VB/20160414 CASE 238895 Added support for filtering of menu lines by register type.
    // NPR5.22/VB/20160414 CASE 238802 Added support for sorting in lookup templates.
    // NPR5.28/VB/20161122 CASE 259086 Removing last remnants of the .NET Control Add-in
    // NPR5.40/BHR /20180322 CASE 308408 Rename variable Grid to PageGrid


    trigger OnRun()
    begin
        SessionMgt.EndPOSSession();
        //-NPR5.28
        //IF SessionMgt.IsDotNet() THEN
        //  PAGE.RUN(PAGE::"Touch Screen - Sale")
        //ELSE
        //+NPR5.28
          PAGE.Run(PAGE::"Touch Screen - Sale (Web)");
    end;

    var
        SessionMgt: Codeunit "POS Web Session Management";
        Util: Codeunit "POS Web Utilities";
        ViewType: DotNet npNetViewType;
        Direction: Option TopBottom,LeftRight;
        MenuPosition: Option Top,Bottom,Menu;
        CaptionLabelReceiptNo: Label 'Sale';
        CaptionLabelEANHeader: Label 'Item No.';
        CaptionLabelLastSale: Label 'Last Sale';
        CaptionFunctionButtonText: Label 'Function';
        CaptionMainMenuButtonText: Label 'Main Menu';
        CaptionLabelReturnAmount: Label 'Balance';
        CaptionLabelRegisterNo: Label 'Register';
        CaptionLabelSalesPersonCode: Label 'Salesperson Code';
        CaptionLabelClear: Label 'Erase';
        CaptionLabelPaymentAmount: Label 'Total';
        CaptionLabelPaymentTotal: Label 'Sale (LCY)';
        CaptionLabelTotalPayed: Label 'Payed';
        CaptionLabelSubtotal: Label 'SUBTOTAL';
        CaptionPaymentInfo: Label 'Payment info';
        CaptionGlobalCancel: Label 'Cancel';
        CaptionGlobalClose: Label 'Close';
        CaptionGlobalBack: Label 'Back';
        CaptionGlobalOK: Label 'OK';
        CaptionGlobalYes: Label 'Yes';
        CaptionGlobalNo: Label 'No';
        CaptionGlobalPrevious: Label 'Previous';
        CaptionGlobalNext: Label 'Next';
        CaptionBalancingRegisterTransactions: Label 'Register Transactions';
        CaptionBalancingRegisters: Label 'Registers';
        CaptionBalancingReceipts: Label 'Receipts';
        CaptionBalancingBeginningBalance: Label 'Beginning Balance';
        CaptionBalancingCashMovements: Label 'Cash Movements';
        CaptionBalancingMidTotal: Label 'Mid-Total';
        CaptionBalancingManualCards: Label 'Credit Cards (Manual)';
        CaptionBalancingTerminalCards: Label 'Credit Cards (Terminal)';
        CaptionBalancingOtherCreditCards: Label 'Credit Cards (Other)';
        CaptionBalancingTerminal: Label 'Terminal';
        CaptionBalancingGiftCards: Label 'Gift Cards';
        CaptionBalancingCreditVouchers: Label 'Credit Vouchers';
        CaptionBalancingCustomerOutPayments: Label 'Customer Out-Payments';
        CaptionBalancingDebitSales: Label 'Debit Sales';
        CaptionBalancingStaffSales: Label 'Staff Sales';
        CaptionBalancingNegativeReceiptAmount: Label 'Negative Receipt Amount';
        CaptionBalancingForeignCurrency: Label 'Foreign Currency';
        CaptionBalancingReceiptStatistics: Label 'Receipt Statistics';
        CaptionBalancingNumberOfSales: Label 'Number Of Sales';
        CaptionBalancingCancelledSales: Label 'Cancelled Sales';
        CaptionBalancingNumberOfNegativeReceipts: Label 'Number of Negative Receipts';
        CaptionBalancingTurnover: Label 'Turnover';
        CaptionBalancingCOGS: Label 'Cost of Goods Sold';
        CaptionBalancingContributionMargin: Label 'Contribution Margin';
        CaptionBalancingDiscounts: Label 'Discounts';
        CaptionBalancingCampaign: Label 'Campaign Discounts';
        CaptionBalancingMixed: Label 'Mixed Discounts';
        CaptionBalancingQuantityDiscounts: Label 'Quantity Discounts';
        CaptionBalancingSalespersonDiscounts: Label 'Salesperson Discounts';
        CaptionBalancingBOMDiscounts: Label 'BOM Discounts';
        CaptionBalancingCustomerDiscounts: Label 'Customer Discounts';
        CaptionBalancingOtherDiscounts: Label 'Other Discounts';
        CaptionBalancingTotalDiscounts: Label 'Total Discounts';
        CaptionBalancingOpenDrawer: Label 'Open Drawer';
        CaptionBalancingAuditRoll: Label 'Audit Roll';
        CaptionBalancingCashCount: Label '%1 Count';
        CaptionBalancingCountedLCY: Label 'Counted (LCY)';
        CaptionBalancingDifferenceLCY: Label 'Difference (LCY)';
        CaptionBalancingNewCashAmount: Label 'New Cash Amount';
        CaptionBalancingPutInTheBank: Label 'Put in the Bank';
        CaptionBalancingMoneybagNo: Label 'Moneybag No.';
        CaptionBalancingAmount: Label 'Amount';
        CaptionBalancingNumber: Label 'Number';
        CaptionBalancingRemainderTransferred: Label 'Remainder Transferred to Safe / Exchange Desk';
        CaptionBalancingDelete: Label 'Delete';
        CaptionBalancingClose: Label 'Close';
        CaptionBalancing1Turnover: Label '[1] Turnover';
        CaptionBalancing2Counting: Label '[2] Counting';
        CaptionBalancing3Close: Label '[3] Close';
        CaptionDataGridSelected: Label 'Selected';
        CaptionLookupSearch: Label 'Search';
        CaptionLookup: Label 'Lookup: ';
        CaptionLookupNew: Label 'New';
        CaptionLookupShowCard: Label 'Show Card';
        CaptionMessage: Label 'You might want to know...';
        CaptionConfirmation: Label 'We need your confirmation...';
        CaptionError: Label 'Something is wrong...';
        CaptionNumpad: Label 'We need more information...';
        CaptionLockedRegisterLocked: Label 'This register is locked';
        CaptionTabletButtonItems: Label 'Items';
        CaptionTabletButtonMore: Label 'More...';
        CaptionTabletButtonPayments: Label 'Payment Methods';

    procedure ConfigureView(View: DotNet npNetSaleView)
    var
        EnumClientType: DotNet npNetClientType;
    begin
        case View.TypeAsInt of
          ViewType.Sale:    ConfigureSaleScreen(View.ToSaleView());
          ViewType.Payment: ConfigurePaymentScreen(View.ToPaymentView());
        end;

        case SESSION.CurrentClientType of
          CLIENTTYPE::Windows:  View.ClientType := EnumClientType.Windows;
          CLIENTTYPE::Web:      View.ClientType := EnumClientType.Web;
          // The following two options are for future compatibility. Tablet compiles under NAV build 41370 (but not earlier), Phone under NAV 2016 builds. Do not remove!
          //CLIENTTYPE::Tablet:   View.ClientType := EnumClientType.Tablet;
          //CLIENTTYPE::Phone:    View.ClientType := EnumClientType.Phone;
          // The following option is a fallback option, for now we keep Web as default. Do not change!
          else
            View.ClientType := EnumClientType.Web;
        end;
    end;

    local procedure ConfigureSaleScreen(View: DotNet npNetSaleView)
    var
        MenuLinesFilter: Record "Touch Screen - Menu Lines";
    begin
        MenuLinesFilter.SetRange(Type,MenuLinesFilter.Type::"Sale Form");
        ConfigureButtonGrids(View,MenuLinesFilter);

        ConfigureSalesLinesGrid(View);

        View.LogKeys := true;
    end;

    local procedure ConfigurePaymentScreen(View: DotNet npNetPaymentView)
    var
        MenuLinesFilter: Record "Touch Screen - Menu Lines";
    begin
        MenuLinesFilter.SetRange(Type,MenuLinesFilter.Type::"Payment Form");
        ConfigureButtonGrids(View,MenuLinesFilter);

        ConfigurePaymentLinesGrid(View);

        View.LogKeys := true;
    end;

    local procedure ConfigureButtonGrids(View: DotNet npNetView;var MenuLines: Record "Touch Screen - Menu Lines")
    var
        MenuLinesFilter: Record "Touch Screen - Menu Lines";
        IMenuButtonView: DotNet npNetIMenuButtonView;
    begin
        IMenuButtonView := View.ToMenuButtonView();

        MenuLines.CopyFilter(Type,MenuLinesFilter.Type);
        MenuLinesFilter.SetRange("Grid Position",MenuLinesFilter."Grid Position"::Right);
        MenuLinesFilter.SetRange("Placement ID",1,6);
        ConfigureButtonGrid(IMenuButtonView.GetFunctionsTop().Initialize(2,3,SessionMgt.ButtonsEnabledByDefault),MenuLinesFilter,Direction::LeftRight,0);

        MenuLines.CopyFilter(Type,MenuLinesFilter.Type);
        MenuLinesFilter.SetRange("Grid Position",MenuLinesFilter."Grid Position"::Right);
        MenuLinesFilter.SetRange("Placement ID",7,15);
        ConfigureButtonGrid(IMenuButtonView.GetFunctionsBottom().Initialize(3,3,SessionMgt.ButtonsEnabledByDefault),MenuLinesFilter,Direction::LeftRight,-6);
        IMenuButtonView.GetFunctionsBottom().Item(2,0).HeightFactor := 2;
        IMenuButtonView.GetFunctionsBottom().Item(2,1).HeightFactor := 2;
        IMenuButtonView.GetFunctionsBottom().Item(2,2).HeightFactor := 2;

        MenuLines.CopyFilter(Type,MenuLinesFilter.Type);
        MenuLinesFilter.SetRange("Grid Position",MenuLinesFilter."Grid Position"::"Bottom Center");
        ConfigureButtonGrid(IMenuButtonView.GetMenu().Initialize(SessionMgt.ButtonCountVertical(),SessionMgt.ButtonCountHorizontal(),SessionMgt.ButtonsEnabledByDefault),MenuLinesFilter,Direction::TopBottom,0);
    end;

    procedure ConfigureButtonGrid(Menu: DotNet npNetButtonGrid;var MenuLines: Record "Touch Screen - Menu Lines";Direction: Option TopBottom,LeftRight;PlacementOffset: Integer)
    var
        MenuLinesTmp: Record "Touch Screen - Menu Lines" temporary;
        IntTmp: Record "Integer" temporary;
        Util: Codeunit "POS Web Utilities";
        ButtonGrid: DotNet npNetButtonGrid;
        PlacementID: Integer;
        Iteration: Integer;
        x: Integer;
        y: Integer;
    begin
        Menu.Initialize(SessionMgt.ButtonsEnabledByDefault);
        Util.MenuInitializePlacementBuffer(IntTmp,Menu.ColumnCount,Menu.RowCount);

        FilterMenuLines(MenuLines);
        if MenuLinesExist(MenuLines,MenuLinesTmp) then
          with MenuLinesTmp do begin
            for Iteration := 1 to 3 do begin
              Reset;
              case Iteration of
                1:
                  begin
                    SetFilter("Placement X",'<>0');
                    SetFilter("Placement Y",'<>0');
                  end;
                2:
                  begin
                    SetCurrentKey("Placement ID");
                    SetFilter("Placement ID",'>0');
                  end;
              end;

              if FindSet(true) then
                repeat
                  case Iteration of
                    1: PlacementID := Util.MenuFindAvailablePlacementID(IntTmp,Util.MenuXYToPlacementID("Placement X","Placement Y",Menu.RowCount,Menu.ColumnCount,Direction));
                    2: PlacementID := Util.MenuFindAvailablePlacementID(IntTmp,"Placement ID" + PlacementOffset);
                    3: PlacementID := Util.MenuFindAvailablePlacementID(IntTmp,0);
                  end;
                  x := Util.MenuPlacementIDToX(PlacementID,Menu.RowCount,Menu.ColumnCount,Direction);
                  y := Util.MenuPlacementIDToY(PlacementID,Menu.RowCount,Menu.ColumnCount,Direction);
                  SetMenuButton(Menu.Item(y - 1,x - 1),MenuLinesTmp,0);
                  Delete;
                  Util.MenuDeletePlacementBuffer(IntTmp,x,y,Menu.RowCount,Menu.ColumnCount,Direction);
                until Next = 0;
            end;
          end;
    end;

    local procedure FilterMenuLines(var MenuLines: Record "Touch Screen - Menu Lines")
    var
        MenuLinesFilter: Record "Touch Screen - Menu Lines";
        LastLine: Record "Touch Screen - Menu Lines";
        Util: Codeunit "POS Web Utilities";
        "Filter": Text;
    begin
        MenuLinesFilter.Copy(MenuLines);

        MenuLines.Reset;
        MenuLines.SetCurrentKey("Placement ID");

        MenuLines.SetRange(Enabled,true);
        MenuLines.SetRange(Visible,true);

        MenuLinesFilter.CopyFilter("Placement ID",MenuLines."Placement ID");
        MenuLines.SetRange(Level,MenuLinesFilter.Level);
        MenuLinesFilter.CopyFilter(Type,MenuLines.Type);
        MenuLinesFilter.CopyFilter("Grid Position",MenuLines."Grid Position");

        //-NPR5.20
        //MenuLines.SETFILTER("Only Visible To",Util.FilterContainsOrBlank(SessionMgt.SalespersonCode));
        //MenuLines.SETFILTER(Terminal,Util.FilterContainsOrBlank(SessionMgt.RegisterNo));
        Filter := Util.FilterContainsOrBlank(SessionMgt.GetSalespersonCode);
        if Filter = '' then
          MenuLines.SetRange("Only Visible To",'')
        else
          MenuLines.SetFilter("Only Visible To",Filter);
        Filter := Util.FilterContainsOrBlank(SessionMgt.RegisterNo);
        if Filter = '' then
          MenuLines.SetRange(Terminal,'')
        else
          MenuLines.SetFilter(Terminal,Filter);
        //+NPR5.20
        //-NPR5.22
        MenuLines.SetFilter("Register Type",'%1|%2',SessionMgt.RegisterType,'');
        //+NPR5.22

        if (MenuLines.Level > 0) and (MenuLines."No." > 0) then begin
          LastLine := MenuLines;
          LastLine.SetFilter(Level,'<%1',MenuLines.Level);
          if LastLine.Find('>') then begin
            LastLine.Reset;
            LastLine.Next(-1);
          end;
          MenuLines.SetRange("No.",MenuLines."No.",LastLine."No.");
        end;
    end;

    local procedure MenuLinesExist(var MenuLines: Record "Touch Screen - Menu Lines";var MenuLinesTmp: Record "Touch Screen - Menu Lines" temporary): Boolean
    begin
        MenuLinesTmp.Reset;
        MenuLinesTmp.DeleteAll;

        if MenuLines.IsEmpty then
          exit(false);

        if MenuLines.FindSet then
          repeat
            MenuLinesTmp := MenuLines;
            MenuLinesTmp.Insert;
          until MenuLines.Next = 0;

        exit(true);
    end;

    local procedure SetMenuButton(Button: DotNet npNetButton;var MenuLine: Record "Touch Screen - Menu Lines";PlacementID: Integer)
    var
        Util: Codeunit "POS Web Utilities";
    begin
        if PlacementID > 0 then begin
          MenuLine.SetRange("Placement ID",PlacementID);
          if not MenuLine.FindFirst then
            exit;
        end;

        Button.MenuLineNo := MenuLine."No.";
        Button.Caption := MenuLine."Text Line 1";
        Button.Enabled := true;
        Button.IconClass := MenuLine."Icon Class";
        Util.AssignColorFromLine(MenuLine,Button);
        Util.AssignShowBehaviorFromLine(MenuLine,Button);
    end;

    procedure ConfigureSalesLinesGrid(View: DotNet npNetSaleView)
    var
        SaleLine: Record "Sale Line POS";
        "Field": Record "Field";
    begin
        Field.SetRange(TableNo,DATABASE::"Sale Line POS");
        Field.SetRange(Enabled,true);
        if Field.FindSet then
          repeat
            if IncludeFieldSale(Field) then
              CreateGridColumn(View.DataGrid,Field);
          until Field.Next = 0;
    end;

    procedure IncludeFieldSale("Field": Record "Field"): Boolean
    var
        RetailSetup: Record "Retail Setup";
        SaleLine: Record "Sale Line POS";
    begin
        RetailSetup.Get;
        if Field.TableNo <> DATABASE::"Sale Line POS" then
          exit(false);

        with SaleLine do
          case Field."No." of
            FieldNo("No."):                   exit(false);
            FieldNo(Type):                    exit(false);
            FieldNo(Description):             exit(true);
            FieldNo("Item Group"): exit(false);
            FieldNo(Color):                   exit(false);
            FieldNo(Size):                    exit(false);
            FieldNo("Label No."):             exit(false);
            FieldNo(Quantity):                exit(true);
            FieldNo("Unit Price"):            exit(true);
            FieldNo("Discount Amount"):       exit(RetailSetup."POS - Show discount fields");
            FieldNo("Discount %"):            exit(RetailSetup."POS - Show discount fields");
            FieldNo("Amount Including VAT"):  exit(true);
          end;

        exit(false);
    end;

    procedure IncludeFieldPayment("Field": Record "Field"): Boolean
    var
        RetailSetup: Record "Retail Setup";
        SaleLine: Record "Sale Line POS";
    begin
        RetailSetup.Get;
        if Field.TableNo <> DATABASE::"Sale Line POS" then
          exit(false);

        with SaleLine do
          case Field."No." of
            FieldNo(Description):             exit(true);
            FieldNo("Currency Amount"):       exit(true);
            FieldNo("Amount Including VAT"):  exit(true);
          end;

        exit(false);
    end;

    procedure IncludeFieldBalancing("Field": Record "Field"): Boolean
    var
        RetailSetup: Record "Retail Setup";
        PaymentType: Record "Payment Type POS";
    begin
        RetailSetup.Get;
        if Field.TableNo <> DATABASE::"Payment Type POS" then
          exit(false);

        with PaymentType do
          case Field."No." of
            FieldNo("No."):                   exit(true);
            FieldNo(Description):             exit(true);
            FieldNo("Amount in Audit Roll"):  exit(true);
            FieldNo("Balancing Total"):       exit(true);
          end;

        exit(false)
    end;

    procedure IncludeFieldExchangeLabels("Field": Record "Field"): Boolean
    var
        RetailSetup: Record "Retail Setup";
        SaleLine: Record "Sale Line POS";
    begin
        RetailSetup.Get;
        if Field.TableNo <> DATABASE::"Sale Line POS" then
          exit(false);

        with SaleLine do
          case Field."No." of
            FieldNo("No."):                   exit(true);
            FieldNo(Description):             exit(true);
            FieldNo("Amount Including VAT"):  exit(true);
          end;

        exit(false);
    end;

    procedure ConfigurePaymentLinesGrid(View: DotNet npNetPaymentView)
    var
        SaleLine: Record "Sale Line POS";
        "Field": Record "Field";
    begin
        Field.SetRange(TableNo,DATABASE::"Sale Line POS");
        Field.SetRange(Enabled,true);
        if Field.FindSet then
          repeat
            if IncludeFieldPayment(Field) then
              CreateGridColumn(View.DataGrid,Field);
          until Field.Next = 0;
    end;

    procedure ConfigureBalancingLinesGrid(PageGrid: DotNet npNetDataGrid)
    var
        "Field": Record "Field";
    begin
        Field.SetRange(TableNo,DATABASE::"Payment Type POS");
        Field.SetRange(Enabled,true);
        if Field.FindSet then
          repeat
            if IncludeFieldBalancing(Field) then
              //-NPR5.40 [308408]
              //CreateGridColumn(Grid,Field);
              CreateGridColumn(PageGrid,Field);
              //+NPR5.40 [308408]
          until Field.Next = 0;
    end;

    procedure ConfigurePrintExchangeLabelsGrid(PageGrid: DotNet npNetDataGrid)
    var
        SaleLine: Record "Sale Line POS";
        "Field": Record "Field";
    begin
        Field.SetRange(TableNo,DATABASE::"Sale Line POS");
        Field.SetRange(Enabled,true);
        if Field.FindSet then
          repeat
            if IncludeFieldExchangeLabels(Field) then
              //-NPR5.40 [308408]
              //CreateGridColumn(Grid,Field);
              CreateGridColumn(PageGrid,Field);
              //+NPR5.40 [308408]
          until Field.Next = 0;

        Field.Init;
        Field.Type := Field.Type::Boolean;
        Field."Field Caption" := CaptionDataGridSelected;
        Field."No." := -65535;
        Field.FieldName := '__marked__';
        Field.Enabled := false;
        //-NPR5.40 [308408]
        //CreateGridColumn(Grid,Field);
        CreateGridColumn(PageGrid,Field);
        //+NPR5.40 [308408]
    end;

    local procedure CreateGridColumn(PageGrid: DotNet npNetDataGrid;"Field": Record "Field")
    var
        SaleLine: Record "Sale Line POS";
        DataColumn: DotNet npNetDataColumn0;
        TextAlign: DotNet npNetTextAlign;
        Format: DotNet npNetNumberFormat;
    begin
        with Field do begin
          DataColumn := DataColumn.DataColumn;
          if Type in [Type::Integer,Type::Decimal,Type::BigInteger] then
            DataColumn.Align := TextAlign.Right
          else
            DataColumn.Align := TextAlign.Left;
          DataColumn.AlignHeader := TextAlign.Center;
          DataColumn.Caption := "Field Caption";
          DataColumn.Field := Util.JavaScriptNameFromField(Field."No.",FieldName);
          case true of
            StrPos(FieldName,'%') > 0:  DataColumn.Format := Format.Percentage;
            Type = Type::Decimal:       DataColumn.Format := Format.Number;
          end;
          if Type = Type::Text then
            DataColumn.Width := 30
          else
            DataColumn.Width := 10;

          if (Type = Type::Boolean) and (not Enabled) then begin
            DataColumn.IsCheckbox := true;
            DataColumn.Align := TextAlign.Center;
          end;
          if "No." = -65535 then
            DataColumn.Field := FieldName;
          //-NPR5.40 [308408]
          //Grid.Columns.Add(DataColumn);
          PageGrid.Columns.Add(DataColumn);
          //+NPR5.40 [308408]
        end;
    end;

    procedure ConfigureCalendarGridDialog(Dlg: DotNet npNetCalendarGrid)
    var
        Arr: DotNet npNetArray;
    begin
        Dlg.CaptionNext := CaptionGlobalNext;
        Dlg.CaptionPrevious := CaptionGlobalPrevious;

        Dlg.KeyFields := Arr.CreateInstance(GetDotNetType(0),2);
        Dlg.KeyFields.SetValue(3,0);
        Dlg.KeyFields.SetValue(4,1);
    end;

    procedure ConfigureLookupTemplate(var Template: DotNet npNetTemplate;var LookupRec: RecordRef)
    var
        Vendor: Record Vendor;
        ItemGroup: Record "Item Group";
        SaleLinePOS: Record "Sale Line POS";
        LookupTemplate: Record "Lookup Template";
        LookupTemplateLine: Record "Lookup Template Line";
        CaptionRecRef: RecordRef;
        SortFieldRef: FieldRef;
        Convert: DotNet npNetConvert;
        Row: DotNet npNetRow;
        Info: DotNet npNetInfo;
        TextAlign: DotNet npNetTextAlign;
        NumberFormat: DotNet npNetNumberFormat;
        LineCaption: Text;
        LastRowNo: Integer;
        AddRow: Boolean;
    begin
        Template := Template.Template();

        //-NPR5.20
        if LookupTemplate.Get(LookupRec.Number) then begin
          //-NPR5.22
          if LookupTemplate."Sort By Field No." > 0 then begin
            SortFieldRef := LookupRec.Field(LookupTemplate."Sort By Field No.");
            LookupRec.SetView(StrSubstNo('SORTING(%1)',SortFieldRef.Name));
            if LookupTemplate."Sorting Order" = LookupTemplate."Sorting Order"::Descending then
              LookupRec.Ascending(false);
          end;
          //+NPR5.22
          LookupTemplate.CalcFields("Has Lines");
          if LookupTemplate."Has Lines" then begin
            LookupTemplateLine.SetRange("Lookup Template Table No.",LookupTemplate."Table No.");
            if not LookupTemplateLine.FindSet(false,false) then
              exit;

            LastRowNo := -1;
            Template.Class := LookupTemplate.Class;
            Template.ValueFieldId := LookupTemplate."Value Field No.";
            repeat
              LineCaption := '';
              case LookupTemplateLine."Caption Type" of
                LookupTemplateLine."Caption Type"::Field:
                  LineCaption := LookupRec.Field(LookupTemplateLine."Caption Field No.").Caption;
                LookupTemplateLine."Caption Type"::Table:
                  begin
                    if LookupTemplateLine."Caption Table No." <> 0 then begin
                      CaptionRecRef.Open(LookupTemplateLine."Caption Table No.");
                      LineCaption := CaptionRecRef.Caption;
                      CaptionRecRef.Close();
                    end;
                  end;
                LookupTemplateLine."Caption Type"::Text:
                  LineCaption := LookupTemplateLine."Caption Text";
              end;

              TextAlign := Convert.ToInt32(LookupTemplateLine."Text Align");
              NumberFormat := Convert.ToInt32(LookupTemplateLine."Number Format");

              if LookupTemplateLine."Row No." <> LastRowNo then begin
                if not IsNull(Row) then
                  Template.Rows.Add(Row);
                Row := Row.Row();
                LastRowNo := LookupTemplateLine."Row No.";
              end;
              Info := Row.AddInfo(
                LookupTemplateLine.Class,
                LineCaption,
                LookupTemplateLine."Field No.",
                TextAlign,
                LookupTemplateLine."Font Size (pt)",
                LookupTemplateLine."Width (CSS)",
                NumberFormat,
                LookupTemplateLine.Searchable);
              if LookupTemplateLine."Related Field No." <> 0 then
                Info.RelatedTableFieldNo := LookupTemplateLine."Related Field No.";
            until LookupTemplateLine.Next = 0;
            if not IsNull(Row) then
              Template.Rows.Add(Row);

            exit;
          end;
        end;
        //+NPR5.20

        case LookupRec.Number of
          //-NPR5.00.03
          DATABASE::Customer:
            begin
              Template.Class := 'customer';
              Template.ValueFieldId := 1;

              Row := Row.Row();
              Row.AddInfo('no',LookupRec.Field(1).Caption,1,TextAlign.Left,16,'calc(15% - 2px)',NumberFormat.None,true);
              Info := Row.AddInfo('address',LookupRec.Field(5).Caption,5,TextAlign.Left,16,'calc(40% - 3px)',NumberFormat.None,true);
              Info := Row.AddInfo('phone',LookupRec.Field(9).Caption,9,TextAlign.Left,16,'calc(25% - 3px)',NumberFormat.None,true);
              Row.AddInfo('balance',LookupRec.Field(58).Caption,58,TextAlign.Right,16,'calc(20% - 2px)',NumberFormat.Number,false);
              Template.Rows.Add(Row);

              Row := Row.Row();
              Row.AddInfo('name','',2,TextAlign.Left,32,'60%',NumberFormat.None,true);
              Row.AddInfo('city',LookupRec.Field(7).Caption,7,TextAlign.Right,24,'calc(40% - 6px)',NumberFormat.Number,true);
              Template.Rows.Add(Row);
            end;
          //+NPR5.00.03
          DATABASE::Item:
            begin
              Template.Class := 'item';
              Template.ValueFieldId := 1;

              Row := Row.Row();
              Row.AddInfo('no',LookupRec.Field(1).Caption,1,TextAlign.Left,16,'calc(25% - 2px)',NumberFormat.None,true);
              Info := Row.AddInfo('category',ItemGroup.TableCaption,6014400,TextAlign.Left,16,'calc(25% - 3px)',NumberFormat.None,false);
              Info.RelatedTableFieldNo := 2;
              Info := Row.AddInfo('vendor',Vendor.TableCaption,31,TextAlign.Left,16,'calc(25% - 3px)',NumberFormat.None,false);
              Info.RelatedTableFieldNo := 2;
              Row.AddInfo('inventory',LookupRec.Field(68).Caption,68,TextAlign.Right,16,'calc(25% - 2px)',NumberFormat.Integer,false);
              Template.Rows.Add(Row);

              Row := Row.Row();
              Row.AddInfo('description','',3,TextAlign.Left,32,'80%',NumberFormat.None,true);
              Row.AddInfo('price',LookupRec.Field(18).Caption,18,TextAlign.Right,24,'calc(20% - 6px)',NumberFormat.Number,false);
              Template.Rows.Add(Row);
            end;
          DATABASE::"Retail List":
            begin
              Template.Class := 'retail-list';
              Template.ValueFieldId := 10;
              Row := Row.Row();
              Row.AddInfo('code',SaleLinePOS.FieldCaption("Variant Code"),10,TextAlign.Left,12,'',NumberFormat.None,true);
              Template.Rows.Add(Row);

              Row := Row.Row();
              Row.AddInfo('caption','',2,TextAlign.Left,32,'',NumberFormat.None,true);
              Template.Rows.Add(Row);
            end;
        end;
    end;

    procedure ConfigureCaptions(Marshaller: DotNet npNetMarshaller)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        NumberFormat: DotNet npNetNumberFormatInfo;
        Captions: DotNet npNetDictionary_Of_T_U;
        i: Integer;
    begin
        Captions := Captions.Dictionary();
        Captions.Add('Sale_ReceiptNo',CaptionLabelReceiptNo);
        Captions.Add('Sale_EANHeader',CaptionLabelEANHeader);
        Captions.Add('Sale_LastSale',CaptionLabelLastSale);
        Captions.Add('Login_FunctionButtonText',CaptionFunctionButtonText);
        Captions.Add('Login_MainMenuButtonText',CaptionMainMenuButtonText);
        Captions.Add('Sale_PaymentAmount',CaptionLabelPaymentAmount);
        Captions.Add('Sale_PaymentTotal',CaptionLabelPaymentTotal);
        Captions.Add('Sale_ReturnAmount',CaptionLabelReturnAmount);
        Captions.Add('Sale_RegisterNo',CaptionLabelRegisterNo);
        Captions.Add('Sale_SalesPersonCode',CaptionLabelSalesPersonCode);
        Captions.Add('Login_Clear',CaptionLabelClear);
        Captions.Add('Sale_SubTotal',CaptionLabelSubtotal);
        Captions.Add('Payment_PaymentInfo',CaptionPaymentInfo);
        Captions.Add('Global_Cancel',CaptionGlobalCancel);
        Captions.Add('Global_Close',CaptionGlobalClose);
        Captions.Add('Global_Back',CaptionGlobalBack);
        Captions.Add('Global_OK',CaptionGlobalOK);
        Captions.Add('Global_Yes',CaptionGlobalYes);
        Captions.Add('Global_No',CaptionGlobalNo);
        Captions.Add('CaptionBalancingRegisterTransactions',CaptionBalancingRegisterTransactions);
        Captions.Add('CaptionBalancingRegisters',CaptionBalancingRegisters);
        Captions.Add('CaptionBalancingReceipts',CaptionBalancingReceipts);
        Captions.Add('CaptionBalancingBeginningBalance',CaptionBalancingBeginningBalance);
        Captions.Add('CaptionBalancingCashMovements',CaptionBalancingCashMovements);
        Captions.Add('CaptionBalancingMidTotal',CaptionBalancingMidTotal);
        Captions.Add('CaptionBalancingManualCards',CaptionBalancingManualCards);
        Captions.Add('CaptionBalancingTerminalCards',CaptionBalancingTerminalCards);
        Captions.Add('CaptionBalancingOtherCreditCards',CaptionBalancingOtherCreditCards);
        Captions.Add('CaptionBalancingTerminal',CaptionBalancingTerminal);
        Captions.Add('CaptionBalancingGiftCards',CaptionBalancingGiftCards);
        Captions.Add('CaptionBalancingCreditVouchers',CaptionBalancingCreditVouchers);
        Captions.Add('CaptionBalancingCustomerOutPayments',CaptionBalancingCustomerOutPayments);
        Captions.Add('CaptionBalancingDebitSales',CaptionBalancingDebitSales);
        Captions.Add('CaptionBalancingStaffSales',CaptionBalancingStaffSales);
        Captions.Add('CaptionBalancingNegativeReceiptAmount',CaptionBalancingNegativeReceiptAmount);
        Captions.Add('CaptionBalancingForeignCurrency',CaptionBalancingForeignCurrency);
        Captions.Add('CaptionBalancingReceiptStatistics',CaptionBalancingReceiptStatistics);
        Captions.Add('CaptionBalancingNumberOfSales',CaptionBalancingNumberOfSales);
        Captions.Add('CaptionBalancingCancelledSales',CaptionBalancingCancelledSales);
        Captions.Add('CaptionBalancingNumberOfNegativeReceipts',CaptionBalancingNumberOfNegativeReceipts);
        Captions.Add('CaptionBalancingTurnover',CaptionBalancingTurnover);
        Captions.Add('CaptionBalancingCOGS',CaptionBalancingCOGS);
        Captions.Add('CaptionBalancingContributionMargin',CaptionBalancingContributionMargin);
        Captions.Add('CaptionBalancingDiscounts',CaptionBalancingDiscounts);
        Captions.Add('CaptionBalancingCampaign',CaptionBalancingCampaign);
        Captions.Add('CaptionBalancingMixed',CaptionBalancingMixed);
        Captions.Add('CaptionBalancingQuantityDiscounts',CaptionBalancingQuantityDiscounts);
        Captions.Add('CaptionBalancingSalespersonDiscounts',CaptionBalancingSalespersonDiscounts);
        Captions.Add('CaptionBalancingBOMDiscounts',CaptionBalancingBOMDiscounts);
        Captions.Add('CaptionBalancingCustomerDiscounts',CaptionBalancingCustomerDiscounts);
        Captions.Add('CaptionBalancingOtherDiscounts',CaptionBalancingOtherDiscounts);
        Captions.Add('CaptionBalancingTotalDiscounts',CaptionBalancingTotalDiscounts);
        Captions.Add('CaptionBalancingOpenDrawer',CaptionBalancingOpenDrawer);
        Captions.Add('CaptionBalancingAuditRoll',CaptionBalancingAuditRoll);
        Captions.Add('CaptionBalancingCashCount',CaptionBalancingCashCount);
        Captions.Add('CaptionBalancingCountedLCY',CaptionBalancingCountedLCY);
        Captions.Add('CaptionBalancingDifferenceLCY',CaptionBalancingDifferenceLCY);
        Captions.Add('CaptionBalancingNewCashAmount',CaptionBalancingNewCashAmount);
        Captions.Add('CaptionBalancingPutInTheBank',CaptionBalancingPutInTheBank);
        Captions.Add('CaptionBalancingMoneybagNo',CaptionBalancingMoneybagNo);
        Captions.Add('CaptionBalancingAmount',CaptionBalancingAmount);
        Captions.Add('CaptionBalancingNumber',CaptionBalancingNumber);
        Captions.Add('CaptionBalancingRemainderTransferred',CaptionBalancingRemainderTransferred);
        Captions.Add('CaptionBalancingDelete',CaptionBalancingDelete);
        Captions.Add('CaptionBalancingClose',CaptionBalancingClose);
        Captions.Add('CaptionBalancing1Turnover',CaptionBalancing1Turnover);
        Captions.Add('CaptionBalancing2Counting',CaptionBalancing2Counting);
        Captions.Add('CaptionBalancing3Close',CaptionBalancing3Close);
        Captions.Add('CaptionDataGridSelected',CaptionDataGridSelected);
        Captions.Add('Lookup_Search',CaptionLookupSearch);
        Captions.Add('Lookup_Caption',CaptionLookup);
        //-NPR5.20
        Captions.Add('Lookup_New',CaptionLookupNew);
        Captions.Add('Lookup_Card',CaptionLookupShowCard);
        //+NPR5.20
        Captions.Add('DialogCaption_Message',CaptionMessage);
        Captions.Add('DialogCaption_Confirmation',CaptionConfirmation);
        Captions.Add('DialogCaption_Error',CaptionError);
        Captions.Add('DialogCaption_Numpad',CaptionNumpad);
        Captions.Add('Locked_RegisterLocked',CaptionLockedRegisterLocked);
        Captions.Add('CaptionTablet_ButtonItems',CaptionTabletButtonItems);
        Captions.Add('CaptionTablet_ButtonMore',CaptionTabletButtonMore);
        Captions.Add('CaptionTablet_ButtonPaymentMethods',CaptionTabletButtonPayments);

        SessionMgt.GetNumberFormat(NumberFormat);
        Captions.Add('NumberFormat_DecimalSeparator',NumberFormat.NumberDecimalSeparator);
        Captions.Add('NumberFormat_ThousandsSeparator',NumberFormat.NumberGroupSeparator);

        RecRef.Open(DATABASE::"Sale Line POS");
        for i := 1 to RecRef.FieldCount do begin
          FieldRef := RecRef.FieldIndex(i);
          Captions.Add(StrSubstNo('Global_Record_%1_Field_%2',RecRef.Number,FieldRef.Number),FieldRef.Caption);
        end;

        Marshaller.SetObjectProperty('NaviPartner.Retail.Localization.captions',Captions);
    end;

    procedure ConfigureFonts(Marshaller: DotNet npNetMarshaller)
    var
        WebFont: Record "POS Web Font";
        Font: DotNet npNetFont;
    begin
        WebFont.SetFilter("Company Name",'%1|%2','',CompanyName);
        if WebFont.FindSet then
          repeat
            WebFont.GetFontDotNet_Obsolete(Font);
            Marshaller.ConfigureFont(Font);
          until WebFont.Next = 0;
    end;

    procedure ConfigureCustomLogo(Marshaller: DotNet npNetMarshaller)
    var
        WebFont: Record "POS Web Font";
        String: DotNet npNetString;
    begin
        if SessionMgt.HasCustomLogo() then begin
          String := SessionMgt.GetCustomLogo();
          Marshaller.SetObjectProperty('NaviPartner.Retail.UI.Logo',String);
        end;
    end;

    procedure FormatInteger(Int: BigInteger): Text
    var
        NumberFormat: DotNet npNetNumberFormatInfo;
        Args: DotNet npNetArray;
        String: DotNet npNetString;
        "Object": DotNet npNetObject;
    begin
        SessionMgt.GetNumberFormat(NumberFormat);
        Args := Args.CreateInstance(GetDotNetType(Object),1);
        Args.SetValue(Int,0);
        exit(String.Format(NumberFormat,'{0:N0}',Args));
    end;

    procedure FormatDecimal(Dec: Decimal): Text
    var
        NumberFormat: DotNet npNetNumberFormatInfo;
        Args: DotNet npNetArray;
        String: DotNet npNetString;
        "Object": DotNet npNetObject;
    begin
        SessionMgt.GetNumberFormat(NumberFormat);
        Args := Args.CreateInstance(GetDotNetType(Object),1);
        Args.SetValue(Dec,0);
        exit(String.Format(NumberFormat,StrSubstNo('{0:N%1}',NumberFormat.NumberDecimalDigits),Args));
    end;

    procedure FormatDate(Date: Date): Text
    var
        DateFormat: DotNet npNetDateTimeFormatInfo;
        Args: DotNet npNetArray;
        String: DotNet npNetString;
        "Object": DotNet npNetObject;
    begin
        SessionMgt.GetDateFormat(DateFormat);
        Args := Args.CreateInstance(GetDotNetType(Object),1);
        Args.SetValue(Date,0);
        exit(String.Format(DateFormat,'{0:d}',Args));
    end;

    procedure ParseInteger(Text: Text): BigInteger
    var
        NumberFormat: DotNet npNetNumberFormatInfo;
        Dec: DotNet npNetDecimal;
        Convert: DotNet npNetConvert;
    begin
        SessionMgt.GetNumberFormat(NumberFormat);
        //-NPR5.00.03
        if Text = '' then
          Text := '0';
        //+NPR5.00.03
        exit(Convert.ToInt64(Dec.Parse(Text,NumberFormat)));
    end;

    procedure ParseDecimal(Text: Text): Decimal
    var
        NumberFormat: DotNet npNetNumberFormatInfo;
        Dec: DotNet npNetDecimal;
    begin
        SessionMgt.GetNumberFormat(NumberFormat);
        //-NPR5.00.03
        if Text = '' then
          Text := '0';
        //+NPR5.00.03
        exit(Dec.Parse(Text,NumberFormat));
    end;

    local procedure PrepareDateForParsing(var String: Text)
    var
        DateFormat: DotNet npNetDateTimeFormatInfo;
        DotNetDateTime: DotNet npNetDateTime;
        RegEx: DotNet npNetRegex;
        DateTimeStyles: DotNet npNetDateTimeStyles;
        NewDate: Date;
        NewDateTime: DateTime;
        FormatString: Text;
        NewString: Text;
        FirstOccurrence: Integer;
        SecondOccurrence: Integer;
        Days: Integer;
        Months: Integer;
        Years: Integer;
        ConstructDate: Boolean;
    begin
        if String = '' then
          String := FormatDate(Today);

        RegEx := RegEx.Regex('^[0-9]+$');

        if RegEx.IsMatch(String) then begin
          SessionMgt.GetDateFormat(DateFormat);
          case StrLen(String) of
            1,2:
              NewDate := DMY2Date(ParseInteger(String),Date2DMY(Today,2),Date2DMY(Today,3));
            3,4:
              begin
                FormatString := DelChr(DelChr(DateFormat.ShortDatePattern,'=','y'),'<>',DateFormat.DateSeparator);
                if UpperCase(CopyStr(FormatString,1)) = 'D' then begin
                  Days := ParseInteger(CopyStr(String,1,2));
                  Months := ParseInteger(CopyStr(String,3));
                end else begin
                  Months := ParseInteger(CopyStr(String,1,2));
                  Days := ParseInteger(CopyStr(String,3));
                end;
                Years := Date2DMY(Today,3);
                ConstructDate := true;
              end;
            5,6:
              begin
                FormatString := DateFormat.ShortDatePattern;
                while String <> '' do begin
                  case UpperCase(CopyStr(FormatString,1,1)) of
                    'D':
                      Days := ParseInteger(CopyStr(String,1,2));
                    'M':
                      Months := ParseInteger(CopyStr(String,1,2));
                    'Y':
                      begin
                        NewString := CopyStr(String,1,2);
                        if StrLen(NewString) = 1 then
                          NewString := '0' + NewString;
                        Years := ParseInteger(CopyStr(Format(Date2DMY(Today,3)),1,2) + NewString);
                      end;
                  end;
                  String := CopyStr(String,3);
                  FormatString := CopyStr(FormatString,StrPos(FormatString,DateFormat.DateSeparator) + 1);
                end;
                ConstructDate := true;
              end;
          end;
          if ConstructDate then
            NewDate := DMY2Date(Days,Months,Years);
          String := FormatDate(NewDate);
        end;
    end;

    procedure ParseDate(String: Text): Date
    var
        DateFormat: DotNet npNetDateTimeFormatInfo;
        Date: DotNet npNetDateTime;
    begin
        SessionMgt.GetDateFormat(DateFormat);

        PrepareDateForParsing(String);
        exit(DT2Date(Date.Parse(String,DateFormat)));
    end;

    procedure TryParseDecimal(var Dec: Decimal;String: Text) Result: Boolean
    var
        NumberFormat: DotNet npNetNumberFormatInfo;
        DotNetDecimal: DotNet npNetDecimal;
        NumberStyles: DotNet npNetNumberStyles;
    begin
        SessionMgt.GetNumberFormat(NumberFormat);
        //-NPR5.00.03
        if String = '' then
          String := '0';
        //+NPR5.00.03
        Result := DotNetDecimal.TryParse(String,NumberStyles.Any,NumberFormat,Dec);
    end;

    procedure TryParseDate(var Date: Date;String: Text) Result: Boolean
    var
        DateFormat: DotNet npNetDateTimeFormatInfo;
        DateTimeStyles: DotNet npNetDateTimeStyles;
        DotNetDateTime: DotNet npNetDateTime;
        DateTime: DateTime;
    begin
        SessionMgt.GetDateFormat(DateFormat);

        PrepareDateForParsing(String);
        Result := DotNetDateTime.TryParse(String,DateFormat,DateTimeStyles.AssumeLocal,DateTime);
        Date := DT2Date(DateTime);
    end;
}

