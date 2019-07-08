page 6014426 "Item Group Subpage"
{
    // NPR4.11/BHR/20150422 CASE 211624 iTEM GROUPS DOES NOT GET SORTED PROPERLY
    // NPR5.20/JDH/20160309 CASE 234014 Removed call to recreate item groups
    // NPR5.23/BRI /20160523 CASE 242360 Removed the field "Used" to fix performance issues
    // NPR5.48/BHR /20190115 CASE 334217 Add field Type and Default field to same as Parent

    Caption = 'Item Group Subform';
    PageType = CardPart;
    SourceTable = "Item Group";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Blocked;Blocked)
                {
                }
                field(Type;Type)
                {
                }
                field("Gen. Prod. Posting Group";"Gen. Prod. Posting Group")
                {
                }
                field("Gen. Bus. Posting Group";"Gen. Bus. Posting Group")
                {
                }
                field("Inventory Posting Group";"Inventory Posting Group")
                {
                }
                field("Item Discount Group";"Item Discount Group")
                {
                }
                field("Used Goods Group";"Used Goods Group")
                {
                }
                field("Mixed Discount Line Exists";"Mixed Discount Line Exists")
                {
                }
                field(Internet;Internet)
                {
                }
                field("Costing Method";"Costing Method")
                {
                }
                field("No. Series";"No. Series")
                {
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
        ItemGroupParent: Record "Item Group";
    begin
        //-NPR4.11
        if GetRangeMin("Parent Item Group No.") = '' then exit;
        //IF GETFILTER("Parent Item Group") = ''  THEN
        //   ERROR(Text0001);
        //+NPR4.11

        if GetRangeMin("Parent Item Group No.") = GetRangeMax("Parent Item Group No.") then begin
          "Parent Item Group No." := GetRangeMin("Parent Item Group No.");
          if ItemGroupParent.Get("Parent Item Group No.") then begin
            Level                      := ItemGroupParent.Level + 1;
            "VAT Prod. Posting Group"  := ItemGroupParent."VAT Prod. Posting Group";
            "VAT Bus. Posting Group"   := ItemGroupParent."VAT Bus. Posting Group";
            //-NPR5.48 [334217]
            Type                       := ItemGroupParent.Type;
            //+NPR5.48 [334217]
          end
          else Error(Text10600000);
        end else Error(Text10600000);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        ItemGroupParent: Record "Item Group";
    begin
        if Count = 0 then exit;
        //-NPR4.11
        if GetFilter("Parent Item Group No.") = ''  then exit;
        //IF GETFILTER("Parent Item Group") = ''  THEN
        //   ERROR(Text0001);
        //+NPR4.11

        if GetRangeMin("Parent Item Group No.") = GetRangeMax("Parent Item Group No.") then begin
          "Parent Item Group No." := GetRangeMin("Parent Item Group No.");
          if ItemGroupParent.Get("Parent Item Group No.") then begin
            Level := ItemGroupParent.Level + 1;
          end else Error(Text10600000);
        end else Error(Text10600000);
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

