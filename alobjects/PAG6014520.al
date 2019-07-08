page 6014520 "Touch Screen - Setup"
{
    // NPR4.11/VB/20150622 CASE 216962 Icon Class added to enable configuring the Font Awesome icon id
    // NPR4.13/VB/20150723 CASE 213003 Hide on Hadheld field added
    // NPR4.15/VB/20150930 CASE 224166 Enabled selecting icon on AssistEdit in the icon class field
    // NPR5.22/RA/20160412 CASE 238896 Migrated function from the 2009 version
    // NPR5.26/OSFI/20160810 CASE 246167 Added conditional lookup for POS Info on the Parametre field
    //   Added action Restructure
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    AutoSplitKey = true;
    Caption = 'Touch Screen - Setup';
    PageType = List;
    PromotedActionCategories = 'New,Process,Prints,Login,Sale,Payment,Balancing,Level,Import/Export';
    SourceTable = "Touch Screen - Menu Lines";

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                IndentationColumn = DescIndent;
                IndentationControls = Description;
                field("No.";"No.")
                {
                }
                field(Visible;Visible)
                {
                }
                field("Line Type";"Line Type")
                {
                }
                field("Filter No.";"Filter No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Text Line 1";"Text Line 1")
                {
                }
                field(Parametre;Parametre)
                {

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        POSInfo: Record "POS Info";
                        POSInfoList: Page "POS Info List";
                    begin
                        //-NPR5.26
                        if "Filter No." = 'POS_INFO' then begin
                          POSInfoList.LookupMode(true);
                          if POSInfoList.RunModal = ACTION::LookupOK then begin
                            POSInfoList.GetRecord(POSInfo);
                            Parametre := POSInfo.Code;
                          end;
                        end;
                        //+NPR5.26
                    end;
                }
                field(Terminal;Terminal)
                {
                }
                field("Only Visible To";"Only Visible To")
                {
                }
                field("Register Type";"Register Type")
                {
                }
                field("Placement ID";"Placement ID")
                {
                }
                field("Button Styling";"Button Styling")
                {
                }
                field("Button Brush";"Button Brush")
                {
                }
                field("Grid Position";"Grid Position")
                {
                }
                field("Icon Resource";"Icon Resource")
                {
                }
                field("Button Image";"Button Image")
                {
                }
                field("Icon Class";"Icon Class")
                {
                    AssistEdit = true;
                    Description = 'NPR5.48';

                    trigger OnAssistEdit()
                    var
                        FontPreview: Page "POS Web Font Preview";
                        NewIconClass: Text;
                    begin
                        NewIconClass := FontPreview.GetIconClass("Icon Class");
                        if NewIconClass <> '' then
                          Validate("Icon Class",NewIconClass);
                    end;
                }
                field("Show Behavior";"Show Behavior")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Login)
            {
                Caption = 'Login';
                Image = HRSetup;
                action(Functions)
                {
                    Caption = 'Functions';
                    Image = Users;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ShowType(Type::Login);
                    end;
                }
                action(Staff)
                {
                    Caption = 'Staff';
                    Image = User;

                    trigger OnAction()
                    begin
                        ShowType(Type::User);
                    end;
                }
            }
            group(Sale)
            {
                Caption = 'Sale';
                Image = Sales;
                action("Item Groups")
                {
                    Caption = 'Item Groups';
                    Image = ItemGroup;
                    Promoted = true;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    begin
                        ShowType(Type::Item);
                    end;
                }
                action(Discounts)
                {
                    Caption = 'Discounts';
                    Image = Discount;
                    Promoted = true;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    begin
                        ShowType(Type::Discount);
                    end;
                }
                action(Prints)
                {
                    Caption = 'Prints';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    begin
                        ShowType(Type::Prints);
                    end;
                }
                action(Insurrance)
                {
                    Caption = 'Insurrance';
                    Image = Insurance;
                    Promoted = true;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    begin
                        ShowType(Type::Insurance);
                    end;
                }
                group("Functions Group")
                {
                    Caption = 'Funktioner';
                    Image = Setup;
                    action("Sales Form")
                    {
                        Caption = 'Sales Form';
                        Image = Form;
                        Promoted = true;
                        PromotedCategory = Category5;

                        trigger OnAction()
                        begin
                            ShowType(Type::"Sale Form");
                        end;
                    }
                    action("Other functions")
                    {
                        Caption = 'Other functions';
                        Image = Opportunity;
                        Promoted = true;
                        PromotedCategory = Category5;

                        trigger OnAction()
                        begin
                            ShowType(Type::"Sale Functions");
                        end;
                    }
                    action("Customer Functions")
                    {
                        Caption = 'Customer Functions';
                        Image = Customer;
                        Promoted = true;
                        PromotedCategory = Category5;

                        trigger OnAction()
                        begin
                            ShowType(Type::"Customer Functions");
                        end;
                    }
                    action("Item Functions")
                    {
                        Caption = 'Item Functions';
                        Image = Item;
                        Promoted = true;
                        PromotedCategory = Category5;

                        trigger OnAction()
                        begin
                            ShowType(Type::"Item Functions");
                        end;
                    }
                }
            }
            group(Payment)
            {
                Caption = 'Payment';
                Image = Payables;
                group("Payment Functions Group")
                {
                    Caption = 'Payment Functions Group';
                    Image = CashFlow;
                    action("Payment Form")
                    {
                        Caption = 'Payment Form';
                        Image = Payment;

                        trigger OnAction()
                        begin
                            ShowType(Type::"Payment Form");
                        end;
                    }
                    action("Other Function")
                    {
                        Caption = 'Other Functions';
                        Image = PaymentJournal;

                        trigger OnAction()
                        begin
                            ShowType(Type::"Payment Functions");
                        end;
                    }
                }
                action("Payment Options")
                {
                    Caption = 'Payment Options';
                    Image = CreditCard;

                    trigger OnAction()
                    begin
                        ShowType(Type::PaymentType);
                    end;
                }
            }
            group(Diverse)
            {
                Caption = 'Aux';
                Image = Administration;
                action(Comments)
                {
                    Caption = 'Comments';
                    Image = Comment;

                    trigger OnAction()
                    begin
                        ShowType(Type::Comment);
                    end;
                }
                action(Keyboard)
                {
                    Caption = 'Keyboard';
                    Image = Register;

                    trigger OnAction()
                    begin
                        ShowType(Type::Keyboard);
                    end;
                }
            }
            group(Level)
            {
                Caption = 'Level';
                action(Indent)
                {
                    Caption = 'Indent';
                    Image = Indent;
                    Promoted = true;
                    PromotedCategory = Category8;
                    ShortCutKey = 'Shift+Alt+Right';

                    trigger OnAction()
                    begin

                        if TheMarked then begin
                          LevelGroupMarked(1);
                          exit;
                        end;

                        if LinkYN then CurrREC.levelGroup(Rec,1)
                        else begin
                           if Level < 9 then Level := Level+1;
                           if not Modify then exit;
                        end;
                    end;
                }
                action(Unindent)
                {
                    Caption = 'Unindent';
                    Image = Undo;
                    Promoted = true;
                    PromotedCategory = Category8;
                    ShortCutKey = 'Shift+Alt+Left';

                    trigger OnAction()
                    begin


                        if TheMarked then begin
                          LevelGroupMarked(-1);
                          exit;
                        end;

                        if LinkYN then CurrREC.levelGroup(Rec,-1)
                        else begin
                          if Level > 0 then Level := Level-1;
                          if not Modify then exit;
                        end;
                    end;
                }
                action(Restructure)
                {
                    Caption = 'Restructure';
                    Image = Compress;

                    trigger OnAction()
                    begin
                        //-238896
                        CurrREC.Restrukturer(Rec, true);
                        //+238896
                    end;
                }
            }
            group(Pictures)
            {
                Caption = 'Pictures';
                action(UpdatePicture)
                {
                    Caption = 'Update Picture';
                    Image = Picture;

                    trigger OnAction()
                    begin
                        UpdatePictureByFunCode(Rec);
                    end;
                }
                action(UpdatePictures)
                {
                    Caption = 'Update all pictures';
                    Image = Picture;

                    trigger OnAction()
                    begin
                        UpdatePictureByFunCodeAll();
                    end;
                }
            }
            group("Import/Export")
            {
                Caption = 'Import/Export';
                action(Export)
                {
                    Caption = 'Export';
                    Image = ExportFile;
                    Promoted = true;
                    PromotedCategory = Category9;

                    trigger OnAction()
                    begin
                        ExportSetup;
                    end;
                }
                action(Import)
                {
                    Caption = 'Import';
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Category9;

                    trigger OnAction()
                    begin
                        ImportSetup;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DescIndent := Level;
    end;

    trigger OnOpenPage()
    begin
        ShowType(1);
    end;

    var
        CurrREC: Record "Touch Screen - Menu Lines";
        "NPR Config": Record "Retail Setup";
        Salesperson: Record "Salesperson/Purchaser";
        Item: Record Item;
        ToLine: Record "Touch Screen - Menu Lines";
        LevelNoElements: Integer;
        RowNo: Integer;
        colno: Integer;
        FSI: Guid;
        LinkYN: Boolean;
        TheMarked: Boolean;
        RegisterTypeFilter: Code[10];
        CurrTheme: Code[30];
        CurrTerm: Code[10];
        CurrUser: Code[10];
        ViewTerminal: Code[10];
        Text00001: Label 'Could not move record.\Use reconstruction on list.\If the problem isn''t solved, contact your solution center! ';
        DescIndent: Integer;
        Text00002: Label 'Overwrite All,Update All,Add Only';
        Text00003: Label 'Choose Method';

    procedure CalcRowCol()
    var
        M: Integer;
    begin
        // calcRowCol

        M := Rec."No.";
        M /= 10000;

        RowNo := Round(M/6,1,'<') +1;
        colno := (M-1) mod 5 +1;
    end;

    procedure MoveUp()
    var
        newrec: Record "Touch Screen - Menu Lines";
        oldrec: Record "Touch Screen - Menu Lines";
        temp1: BigInteger;
    begin
        if LinkYN then begin
           CurrREC.Restrukturer(Rec, false);
           Commit;
           CurrREC.moveGroup(Rec,-1);
           //currrec.moveMarked(Rec,-1);
           exit;
        end;

        oldrec := Rec;
        newrec.Copy(Rec);

        if Next(-1) = 0 then exit;

        temp1 := "No.";

        if Next(-1) = 0 then begin
           newrec."No." := Round(temp1/2,1);
           if not newrec.Insert then Error(Text00001)
           else oldrec.Delete;
        end else begin
           newrec."No." := Round((temp1 + "No.")/2,1);
           if not newrec.Insert then Error(Text00001)
           else oldrec.Delete;
        end;

        Next(1);
    end;

    procedure MoveDown()
    var
        newrec: Record "Touch Screen - Menu Lines";
        oldrec: Record "Touch Screen - Menu Lines";
        delrec: Record "Touch Screen - Menu Lines";
        temp1: BigInteger;
        temp2: BigInteger;
    begin



        if LinkYN then begin
           CurrREC.Restrukturer(Rec, false);
           Commit;
           CurrREC.moveGroup(Rec,1);
           //currrec.moveMarked(Rec,1);
           exit;
        end;

        oldrec := Rec;
        newrec.Copy(Rec);

        if Next = 0 then exit;

        temp1 := "No.";

        if Next = 0 then begin
           newrec."No." := temp1 + 10000;
           if not newrec.Insert then Error(Text00001)
           else oldrec.Delete;
        end else begin
           newrec."No." := Round((temp1 + "No.")/2,1);
           if not newrec.Insert then Error(Text00001)
           else oldrec.Delete;
        end;

        Next(-1);
    end;

    procedure MoveIn()
    begin
    end;

    procedure MoveOut()
    begin
    end;

    procedure LevelGroupMarked(Direction: Integer): Boolean
    var
        cl: Integer;
    begin

        MarkedOnly(true);

        if not Find('-') then begin
          MarkedOnly(false);
          Error('sdf');
          if Find('-') then;
          exit(false);
        end;

        if (Direction < 0) and (Level = 0) then exit(false);
        if (Direction > 0) and (Level = 10) then exit(false);

        repeat
          Level += Direction;
          Modify;
        until (Next = 0);

        MarkedOnly(false);
    end;

    procedure InsertBlank()
    var
        newrec: Record "Touch Screen - Menu Lines";
        oldrec: Record "Touch Screen - Menu Lines";
        temp1: BigInteger;
    begin
        newrec := Rec;

        temp1 := "No.";

        newrec."Filter No." := '';
        newrec."Only Visible To" := '';
        newrec.Bitmap := '';
        newrec.Enabled := true;
        newrec.Password := '';
        newrec."Line Type" := newrec."Line Type"::Item;
        newrec.Description := '< BLANK >';
        newrec."Text Line 1" := '';

        if Next(-1) = 0 then begin
           newrec."No." := Round(temp1/2,1);
           if not newrec.Insert then Error(Text00001);
        end else begin
           newrec."No." := Round((temp1 + "No.")/2,1);
           if not newrec.Insert then Error(Text00001)
        end;

        Rec := newrec;
    end;

    procedure ShowType(toType: Integer)
    begin
        Reset;

        SetRange(Type, toType);
        if Find('-') then;

        CurrPage.Update(false);

        // CurrREC.Restrukturer(Rec, FALSE);
    end;

    procedure ValidateRange()
    begin
        //ValidateRange

        if Find('-') then repeat
          Validate("Filter No.");
        until Next = 0;

        if Find('-') then;
    end;

    procedure UpdatePictureByFunCode(MenuLine: Record "Touch Screen - Menu Lines")
    var
        Images: Record "Product / Button  Images";
    begin
        if (MenuLine."Line Type" <> MenuLine."Line Type"::Internal) then exit;
        Images.SetRange(Purpose,Images.Purpose::"Touch Screen");
        Images.SetRange("No.",MenuLine."Filter No.");
        if Images.FindFirst then begin
          MenuLine.Validate("Icon Resource",Images."No.");
          MenuLine.Modify;
        end;
    end;

    procedure UpdatePictureByFunCodeAll()
    var
        MenuLine: Record "Touch Screen - Menu Lines";
    begin
        MenuLine.ModifyAll("Icon Resource",'');
        MenuLine.SetRange("Line Type",MenuLine."Line Type"::Internal);
        if MenuLine.FindSet then repeat
          UpdatePictureByFunCode(MenuLine);
        until MenuLine.Next = 0;

        CurrPage.Update(false)
    end;

    procedure ExportSetup()
    var
        TableExportLibrary: Codeunit "Table Export Library";
    begin
        TableExportLibrary.SetFileModeDotNetStream();
        TableExportLibrary.SetShowStatus(true);
        TableExportLibrary.SetWriteTableInformation(true);
        TableExportLibrary.AddTableForExport(DATABASE::"Touch Screen - Menu Lines");
        TableExportLibrary.ExportTableBatch;
    end;

    procedure ImportSetup()
    var
        TableImportLibrary: Codeunit "Table Import Library";
        TouchScreenMenuLines: Record "Touch Screen - Menu Lines";
    begin
        case StrMenu(Text00002,0,Text00003) of
          1 : begin
                TouchScreenMenuLines.DeleteAll;
                TableImportLibrary.SetAutoSave(true);
              end;
          2 : begin
                TableImportLibrary.SetAutoSave(true);
                TableImportLibrary.SetAutoUpdate(true);
              end;
          3 : begin
                TableImportLibrary.SetAutoSave(true);
              end;
        end;

        TableImportLibrary.SetExpectedTable(DATABASE::"Touch Screen - Menu Lines");
        TableImportLibrary.SetShowStatus(true);
        TableImportLibrary.SetFileModeDotNetStream;
        TableImportLibrary.ImportTableBatch;
    end;
}

