page 6150832 "NPR HL Select MCF Options"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = false;
    Caption = 'HL Select MC Field Options';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "NPR HL MultiChoice Fld Option";
    SourceTableView = sorting("Field Code", "Sort Order");
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Selected; Selected)
                {
                    ApplicationArea = NPRHeyLoyalty;
                    Caption = 'Selected';
                    ToolTip = 'Specifies wether this HeyLoyalty field option value is selected.';
                    Editable = true;

                    trigger OnValidate()
                    begin
                        Rec.Mark(Selected);
                    end;
                }
                field("Field Code"; Rec."Field Code")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the code of the HeyLoyalty multiple choice field.';
                    Visible = FieldCodeVisibile;
                    Editable = false;
                }
                field("Option ID"; Rec."Option ID")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies a BC internal identifier of this HeyLoyalty multiple choice field option value.';
                    Visible = false;
                    Editable = false;
                }
                field("Sort Order"; Rec."Sort Order")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the sort order of the option value. The lower the number, the higher in the list the option value will appear.';
                    Visible = false;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies an explanation of the HeyLoyalty multiple choice field option value.';
                    Editable = false;
                }
                field("Magento Description"; Rec."Magento Description")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the id used for the field option value at Magento.';
                    Visible = false;
                    Editable = false;
                }
                field("HeyLoyalty Field Name"; HeyLoyaltyName)
                {
                    ApplicationArea = NPRHeyLoyalty;
                    Caption = 'HeyLoyalty Field Name';
                    ToolTip = 'Specifies the id used for the field option value at HeyLoyalty.';
                    Visible = false;
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        FieldCodeFromFilter: Code[20];
    begin
        FieldCodeFromFilter := Rec.GetFieldCodeFilter();
        FieldCodeVisibile := FieldCodeFromFilter = '';
    end;

    trigger OnAfterGetRecord()
    begin
        Selected := Rec.Mark();
        HeyLoyaltyName := HLMappedValueMgt.GetMappedValue(Rec.RecordId(), Rec.FieldNo(Description), false);
    end;

    internal procedure SetDataset(var HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option")
    begin
        Rec.Copy(HLMultiChoiceFldOption);
    end;

    internal procedure GetDataset(var HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        i: Integer;
    begin
        HLMultiChoiceFldOption.Copy(Rec);
        if HLMultiChoiceFldOption.GetFilters() <> '' then begin
            RecRef.GetTable(HLMultiChoiceFldOption);
            for i := 1 to RecRef.FieldCount do begin
                FldRef := RecRef.FieldIndex(i);
                if FldRef.GetFilter <> '' then
                    FldRef.SetRange();
            end;
        end;
    end;

    var
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        HeyLoyaltyName: Text[100];
        FieldCodeVisibile: Boolean;
        Selected: Boolean;
}
