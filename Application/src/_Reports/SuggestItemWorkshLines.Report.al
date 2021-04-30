report 6060040 "NPR Suggest Item Worksh. Lines"
{
    Caption = 'Suggest Item Worksheet Lines';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("Item Worksheet"; "NPR Item Worksheet")
        {
            dataitem(Item; Item)
            {
                RequestFilterFields = "No.";

                trigger OnAfterGetRecord()
                begin
                    LineNo := LineNo + 10000;
                    ItemWorksheetLine.Reset();
                    ItemWorksheetLine.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
                    ItemWorksheetLine.SetRange("Worksheet Name", "Item Worksheet".Name);
                    ItemWorksheetLine.SetRange("Existing Item No.", Item."No.");
                    if not ItemWorksheetLine.FindFirst() then begin
                        ItemWorksheetLine.Init();
                        ItemWorksheetLine.Validate("Worksheet Template Name", "Item Worksheet"."Item Template Name");
                        ItemWorksheetLine.Validate("Worksheet Name", "Item Worksheet".Name);
                        ItemWorksheetLine.Validate("Line No.", LineNo);
                        ItemWorksheetLine.Insert(true);
                        ItemWorksheetLine.Validate("Existing Item No.", Item."No.");
                        ItemWorksheetLine.Validate(ItemWorksheetLine.Action, OptDefaultAction);
                        if ItemWorksheetLine.Action = ItemWorksheetLine.Action::CreateNew then
                            if ItemWorksheetLine."Variety Group" <> '' then
                                ItemWorksheetLine.Validate("Variety Group")
                            else begin
                                if ItemWorksheetLine."Variety 1 Table (Base)" <> '' then
                                    ItemWorksheetLine.Validate("Variety 1 Table (Base)");
                                if ItemWorksheetLine."Variety 2 Table (Base)" <> '' then
                                    ItemWorksheetLine.Validate("Variety 2 Table (Base)");
                                if ItemWorksheetLine."Variety 3 Table (Base)" <> '' then
                                    ItemWorksheetLine.Validate("Variety 3 Table (Base)");
                                if ItemWorksheetLine."Variety 4 Table (Base)" <> '' then
                                    ItemWorksheetLine.Validate("Variety 4 Table (Base)");
                            end;
                        Modify(true);

                        if (OptVariants <> OptVariants::None) then
                            ItemWorksheetLine.RefreshVariants(OptVariants, true);
                        Commit();
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                ItemWorksheetLine.Reset();
                ItemWorksheetLine.SetRange("Worksheet Template Name", "Item Template Name");
                ItemWorksheetLine.SetRange("Worksheet Name", Name);
                if ItemWorksheetLine.FindLast() then
                    LineNo := ItemWorksheetLine."Line No."
                else
                    LineNo := 0;
            end;

            trigger OnPreDataItem()
            begin
                if "Item Worksheet".Count() > 1 then
                    Error(SelectOneItemErr);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(Variants; OptVariants)
                {
                    ApplicationArea = All;
                    OptionCaption = 'None,Variants,Varieties Without Variants,All';
                    ToolTip = 'Specifies the value of the OptVariants field';
                }
                field(Defaults; OptDefaultAction)
                {
                    ApplicationArea = All;
                    OptionCaption = 'Skip,Create New,Update Only,Update and Create Variants';
                    ToolTip = 'Specifies the value of the OptDefaultAction field';
                }
            }
        }

    }

    var
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        LineNo: Integer;
        SelectOneItemErr: Label 'Please select only one Item Worksheet.';
        OptVariants: Option "None",Variants,"Varieties Without Variants",All;
        OptDefaultAction: Option Skip,"Create New","Update Only","Update and Create Variants";
}

