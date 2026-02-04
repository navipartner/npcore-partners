page 6184864 "NPR TM DynamicPriceItemList"
{
    Extensible = false;
    Caption = 'Item Dynamic Price Profile Setup';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR TM DynamicPriceItemList";
    SourceTableTemporary = true;
    InsertAllowed = false;
    PromotedActionCategories = 'New,Process,Report,Actions';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(ItemNo; Rec.ItemNo)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Item No. field.';
                    Editable = false;
                }
                field(VariantCode; Rec.VariantCode)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Variant Code field.';
                    Visible = false;
                    Editable = false;
                }
                field(AdmissionCode; Rec.AdmissionCode)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field.';
                    Editable = false;
                }
                field(ScheduleCode; Rec.ScheduleCode)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Schedule Code field.';
                    Editable = false;
                }
                field(AdmissionSchedulePriceCode; Rec.AdmissionSchedulePriceCode)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Dynamic Price Profile Code, specified on the Admission Schedule Line entry.';
                    Editable = false;
                }
                field(ItemPriceCode; Rec.ItemPriceCode)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Item Price Profile Code field.';

                    trigger OnValidate()
                    var
                        ItemDynamicPrice: Record "NPR TM DynamicPriceItemList";
                    begin
                        if (not ItemDynamicPrice.Get(Rec.ItemNo, Rec.VariantCode, Rec.AdmissionCode, Rec.ScheduleCode)) then begin
                            ItemDynamicPrice.TransferFields(Rec, true);
                            ItemDynamicPrice.Insert();
                        end;
                        ItemDynamicPrice.ItemPriceCode := Rec.ItemPriceCode;
                        ItemDynamicPrice.Modify();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            Action(PriceSimulation)
            {
                Caption = 'Price Simulation';
                ToolTip = 'Navigate to Dynamic Prices Simulation';
                ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                PromotedCategory = Category4;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                Image = Price;

                trigger OnAction()
                var
                    ItemProfileList: Page "NPR TM Price Profile Simulator";
                    PriceCode: Code[10];
                begin
                    PriceCode := Rec.AdmissionSchedulePriceCode;
                    if (Rec.ItemPriceCode <> '') then
                        PriceCode := Rec.ItemPriceCode;

                    ItemProfileList.Initialize(PriceCode, Rec.ItemNo, Rec.VariantCode, Rec.AdmissionCode);
                    ItemProfileList.Run();
                end;
            }
        }
    }

    internal procedure SetPriceViewItemAdmission(ItemNoProfile: Code[20]; VariantCodeP: Code[10]; AdmissionCodeP: Code[20])
    var
        DynamicPrice: Codeunit "NPR TM Dynamic Price";
    begin
        if (Rec.IsTemporary) then
            Rec.DeleteAll();

        DynamicPrice.FindPriceProfiles(ItemNoProfile, VariantCodeP, AdmissionCodeP, Rec);
    end;

    internal procedure SetPriceViewAdmissionSchedule(AdmissionCodeP: Code[20]; ScheduleCodeP: Code[20])
    var
        DynamicPrice: Codeunit "NPR TM Dynamic Price";
    begin
        if (Rec.IsTemporary) then
            Rec.DeleteAll();

        DynamicPrice.FindPriceProfiles(AdmissionCodeP, ScheduleCodeP, Rec);
    end;

    internal procedure SetPriceViewProfileCode(ProfileCode: Code[10])
    var
        DynamicPrice: Codeunit "NPR TM Dynamic Price";
    begin
        if (Rec.IsTemporary) then
            Rec.DeleteAll();

        DynamicPrice.FindPriceProfiles(ProfileCode, Rec);
    end;

}