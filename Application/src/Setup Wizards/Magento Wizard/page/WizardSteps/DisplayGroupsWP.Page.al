page 6014616 "NPR Display Groups WP"
{
    Caption = 'Display Groups';
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Display Group";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Code field';

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInMagDisplayGroup(TempExistingMagDisplayGroups, Rec.Code);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CopyReal();
    end;

    var
        TempExistingMagDisplayGroups: Record "NPR Magento Display Group" temporary;

    procedure CopyRealAndTemp(var TempMagentoDisplayGroup: Record "NPR Magento Display Group")
    var
        MagentoDisplayGroup: Record "NPR Magento Display Group";
    begin
        TempMagentoDisplayGroup.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempMagentoDisplayGroup := Rec;
                TempMagentoDisplayGroup.Insert();
            until Rec.Next() = 0;

        TempMagentoDisplayGroup.Init();
        if MagentoDisplayGroup.FindSet() then
            repeat
                TempMagentoDisplayGroup.TransferFields(MagentoDisplayGroup);
                TempMagentoDisplayGroup.Insert();
            until MagentoDisplayGroup.Next() = 0;
    end;

    procedure CreateMagentoDisplayGroup()
    var
        MagentoDisplayGroup: Record "NPR Magento Display Group";
    begin
        if Rec.FindSet() then
            repeat
                MagentoDisplayGroup := Rec;
                if not MagentoDisplayGroup.Insert() then
                    MagentoDisplayGroup.Modify();
            until Rec.Next() = 0;
    end;

    procedure MagentoDisplayGroupToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    local procedure CopyReal()
    var
        MagentoDisplayGroup: Record "NPR Magento Display Group";
    begin
        if MagentoDisplayGroup.FindSet() then
            repeat
                TempExistingMagDisplayGroups := MagentoDisplayGroup;
                TempExistingMagDisplayGroups.Insert();
            until MagentoDisplayGroup.Next() = 0;
    end;

    local procedure CheckIfNoAvailableInMagDisplayGroup(var MagDisplayGroup: Record "NPR Magento Display Group"; var WantedStartingNo: Code[20]) CalculatedNo: Code[20]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        MagDisplayGroup.SetRange(Code, CalculatedNo);

        if MagDisplayGroup.FindFirst() then begin
            WantedStartingNo := HelperFunctions.FormatCode20(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInMagDisplayGroup(MagDisplayGroup, WantedStartingNo);
        end;
    end;
}
