codeunit 6059923 "NPR NpIa Item AddOn Line Setup"
{
    Access = Internal;

    procedure GetUnitPricePctFromMaster(AddOnNo: Code[20]; AddOnLineNo: Integer): Decimal
    var
        NpIaItemAddOnLineSetup: Record "NPR NpIa ItemAddOn Line Setup";
    begin
        if not NpIaItemAddOnLineSetup.Get(AddOnNo, AddOnLineNo) then
            exit;
        exit(NpIaItemAddOnLineSetup."Unit Price % from Master");
    end;

    procedure UnitPriceFromMasterRunSetup(AddOnNo: Code[20]; AddOnLineNo: Integer)
    var
        NpIaItemAddOnLineSetup: Record "NPR NpIa ItemAddOn Line Setup";
    begin
        NpIaItemAddOnLineSetup.FilterGroup(2);
        NpIaItemAddOnLineSetup.SetRange("AddOn No.", AddOnNo);
        NpIaItemAddOnLineSetup.SetRange("AddOn Line No.", AddOnLineNo);
        NpIaItemAddOnLineSetup.FilterGroup(0);
        if not NpIaItemAddOnLineSetup.Get(AddOnNo, AddOnLineNo) then begin
            NpIaItemAddOnLineSetup.Init();
            NpIaItemAddOnLineSetup."AddOn No." := AddOnNo;
            NpIaItemAddOnLineSetup."AddOn Line No." := AddOnLineNo;
            NpIaItemAddOnLineSetup.Insert();
        end;
        PAGE.Run(PAGE::"NPR NpIa ItemAddOn Line Setup", NpIaItemAddOnLineSetup);
    end;  

    procedure DeleteSetup(AddOnNo: Code[20]; AddOnLineNo: Integer)
    var
        NpIaItemAddOnLineSetup: Record "NPR NpIa ItemAddOn Line Setup";
    begin
        if NpIaItemAddOnLineSetup.Get(AddOnNo, AddOnLineNo) then
            NpIaItemAddOnLineSetup.Delete();        
    end;      
}