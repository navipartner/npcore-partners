page 6014426 "NPR Item Group Subpage"
{
    // NPR4.11/BHR/20150422 CASE 211624 iTEM GROUPS DOES NOT GET SORTED PROPERLY
    // NPR5.20/JDH/20160309 CASE 234014 Removed call to recreate item groups
    // NPR5.23/BRI /20160523 CASE 242360 Removed the field "Used" to fix performance issues
    // NPR5.48/BHR /20190115 CASE 334217 Add field Type and Default field to same as Parent

    Caption = 'Item Group Subform';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Item Group";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field';
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                }
                field("Inventory Posting Group"; "Inventory Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory Posting Group field';
                }
                field("Item Discount Group"; "Item Discount Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Discount Group field';
                }
                field("Used Goods Group"; "Used Goods Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Used Goods Group field';
                }
                field("Mixed Discount Line Exists"; "Mixed Discount Line Exists")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mixed Discount Line Exists field';
                }
                field(Internet; Internet)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Internet field';
                }
                field("Costing Method"; "Costing Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Costing Method field';
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnClosePage()
    begin
        //-NPR5.20
        //CODEUNIT.RUN(CODEUNIT::"Create Item Group Structure");
        //+NPR5.20
    end;

    trigger OnInit()
    begin
        CurrPage.LookupMode := false;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ItemGroupParent: Record "NPR Item Group";
    begin
        //-NPR4.11
        if GetRangeMin("Parent Item Group No.") = '' then exit;
        //IF GETFILTER("Parent Item Group") = ''  THEN
        //   ERROR(Text0001);
        //+NPR4.11

        if GetRangeMin("Parent Item Group No.") = GetRangeMax("Parent Item Group No.") then begin
            "Parent Item Group No." := GetRangeMin("Parent Item Group No.");
            if ItemGroupParent.Get("Parent Item Group No.") then begin
                Level := ItemGroupParent.Level + 1;
                "VAT Prod. Posting Group" := ItemGroupParent."VAT Prod. Posting Group";
                "VAT Bus. Posting Group" := ItemGroupParent."VAT Bus. Posting Group";
                //-NPR5.48 [334217]
                Type := ItemGroupParent.Type;
                //+NPR5.48 [334217]
            end
            else
                Error(Text10600000);
        end else
            Error(Text10600000);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        ItemGroupParent: Record "NPR Item Group";
    begin
        if Count = 0 then exit;
        //-NPR4.11
        if GetFilter("Parent Item Group No.") = '' then exit;
        //IF GETFILTER("Parent Item Group") = ''  THEN
        //   ERROR(Text0001);
        //+NPR4.11

        if GetRangeMin("Parent Item Group No.") = GetRangeMax("Parent Item Group No.") then begin
            "Parent Item Group No." := GetRangeMin("Parent Item Group No.");
            if ItemGroupParent.Get("Parent Item Group No.") then begin
                Level := ItemGroupParent.Level + 1;
            end else
                Error(Text10600000);
        end else
            Error(Text10600000);
    end;

    var
        Text10600000: Label 'Error in delimitation';
        Text0001: Label 'Parent Item Group cannot be blank.';

    local procedure NoOnDeactivate()
    begin
        if "No." = '' then exit
    end;

    local procedure DescriptionOnActivate()
    begin
        if "No." = '' then;
    end;
}

