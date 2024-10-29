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

    internal procedure SetPriceViewItemAdmission(ItemNoP: Code[20]; VariantCodeP: Code[10]; AdmissionCodeP: Code[20])
    var
        DynamicPriceList: Record "NPR TM DynamicPriceItemList";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        AdmissionScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        if (not Rec.IsTemporary) then
            Error('This function can only be called on a temporary record.');

        if (Rec.IsTemporary) then
            Rec.DeleteAll();

        // Current item price profiles
        DynamicPriceList.SetFilter(ItemNo, '=%1', ItemNoP);
        if (DynamicPriceList.FindSet()) then begin
            repeat
                Rec.TransferFields(DynamicPriceList, true);
                Rec.SystemId := DynamicPriceList.SystemId;
                if (not Rec.Insert()) then;
            until (DynamicPriceList.Next() = 0);
        end;

        // All item price profiles
        TicketBOM.SetFilter("Item No.", '=%1', ItemNoP);
        TicketBOM.SetFilter("Variant Code", '=%1', VariantCodeP);
        TicketBOM.SetFilter("Admission Code", '=%1', AdmissionCodeP);
        if (TicketBOM.FindSet()) then begin
            repeat
                AdmissionScheduleLine.SetCurrentKey("Admission Code", "Schedule Code");
                AdmissionScheduleLine.SetFilter("Admission Code", '=%1', AdmissionCodeP);
                if (AdmissionScheduleLine.FindSet()) then begin
                    repeat
                        Rec.Init();
                        Rec.ItemNo := ItemNoP;
                        Rec.VariantCode := TicketBOM."Variant Code";
                        Rec.AdmissionCode := AdmissionCodeP;
                        Rec.ScheduleCode := AdmissionScheduleLine."Schedule Code";
                        if (not Rec.Insert()) then;
                    until (AdmissionScheduleLine.Next() = 0);
                end;
            until (TicketBOM.Next() = 0);
        end;
    end;

    internal procedure SetPriceViewAdmissionSchedule(AdmissionCodeP: Code[20]; ScheduleCodeP: Code[20])
    var
        DynamicPriceList: Record "NPR TM DynamicPriceItemList";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        AdmissionScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        if (not Rec.IsTemporary) then
            Error('This function can only be called on a temporary record.');

        if (Rec.IsTemporary) then
            Rec.DeleteAll();

        // Current item price profiles
        DynamicPriceList.SetFilter(AdmissionCode, '=%1', AdmissionCodeP);
        DynamicPriceList.SetFilter(ScheduleCode, '=%1', ScheduleCodeP);
        if (DynamicPriceList.FindSet()) then begin
            repeat
                Rec.TransferFields(DynamicPriceList, true);
                Rec.SystemId := DynamicPriceList.SystemId;
                if (not Rec.Insert()) then;
            until (DynamicPriceList.Next() = 0);
        end;

        TicketBOM.SetCurrentKey("Admission Code");
        TicketBOM.SetFilter("Admission Code", '=%1', AdmissionCodeP);
        if (TicketBOM.FindSet()) then begin
            repeat
                AdmissionScheduleLine.SetCurrentKey("Admission Code", "Schedule Code");
                AdmissionScheduleLine.SetFilter("Admission Code", '=%1', AdmissionCodeP);
                AdmissionScheduleLine.SetFilter("Schedule Code", '=%1', ScheduleCodeP);
                if (AdmissionScheduleLine.FindSet()) then begin
                    repeat
                        Rec.Init();
                        Rec.ItemNo := TicketBOM."Item No.";
                        Rec.VariantCode := TicketBOM."Variant Code";
                        Rec.AdmissionCode := AdmissionCodeP;
                        Rec.ScheduleCode := AdmissionScheduleLine."Schedule Code";
                        if (not Rec.Insert()) then;
                    until (AdmissionScheduleLine.Next() = 0);
                end;
            until (TicketBOM.Next() = 0);
        end;
    end;

    internal procedure SetPriceViewProfileCode(ProfileCode: Code[10])
    var
        DynamicPriceList: Record "NPR TM DynamicPriceItemList";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        AdmissionScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        if (not Rec.IsTemporary) then
            Error('This function can only be called on a temporary record.');

        if (Rec.IsTemporary) then
            Rec.DeleteAll();

        // Current item price profiles
        DynamicPriceList.SetFilter(ItemPriceCode, '=%1', ProfileCode);
        if (DynamicPriceList.FindSet()) then begin
            repeat
                Rec.TransferFields(DynamicPriceList, true);
                Rec.SystemId := DynamicPriceList.SystemId;
                if (not Rec.Insert()) then;
            until (DynamicPriceList.Next() = 0);
        end;

        AdmissionScheduleLine.SetFilter("Dynamic Price Profile Code", '=%1', ProfileCode);
        if (AdmissionScheduleLine.FindSet()) then begin
            repeat
                TicketBOM.SetCurrentKey("Admission Code");
                TicketBOM.SetFilter("Admission Code", '=%1', AdmissionScheduleLine."Admission Code");
                if (TicketBOM.FindSet()) then begin
                    repeat
                        Rec.Init();
                        Rec.ItemNo := TicketBOM."Item No.";
                        Rec.VariantCode := TicketBOM."Variant Code";
                        Rec.AdmissionCode := TicketBOM."Admission Code";
                        Rec.ScheduleCode := AdmissionScheduleLine."Schedule Code";
                        if (DynamicPriceList.Get(Rec.ItemNo, Rec.VariantCode, Rec.AdmissionCode, Rec.ScheduleCode)) then begin
                            Rec.TransferFields(DynamicPriceList, true);
                            Rec.SystemId := DynamicPriceList.SystemId;
                        end;
                        if (not Rec.Insert()) then;
                    until (TicketBOM.Next() = 0);
                end;
            until (AdmissionScheduleLine.Next() = 0);
        end;
    end;

}