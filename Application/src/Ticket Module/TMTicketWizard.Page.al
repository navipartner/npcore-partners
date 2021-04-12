page 6151133 "NPR TM Ticket Wizard"
{
    Caption = 'Ticket Setup Wizard';
    DataCaptionExpression = Rec.Description;
    DataCaptionFields = Description;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "NPR TM Ticket Type";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(TicketTypeCode; TmpTicketTypeCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Code';
                    ShowMandatory = true;
                    TableRelation = "NPR TM Ticket Type".Code;
                    ToolTip = 'Specifies the value of the Code field';

                    trigger OnValidate()
                    begin
                        ValidateTicketTypeCode();
                    end;
                }
                field(ItemNo; TmpItemNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'No.';
                    TableRelation = Item;
                    ToolTip = 'Specifies the value of the No. field';

                    trigger OnValidate()
                    begin
                        ValidateItemNo();
                    end;
                }
                field(Description; TmpDescription)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Description';
                    Editable = NOT (ItemNumberValid);
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Description field';

                    trigger OnValidate()
                    begin
                        if (not TicketTypeCodeValid) then
                            TmpTicketTypeDescription := TmpDescription;

                        if (not AdmissionCodeValid) then
                            TmpAdmissionDescription := TmpDescription;
                    end;
                }
                field(ItemGroup; TmpItemCategory)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Item Group';
                    Editable = NOT (ItemNumberValid);
                    ShowMandatory = true;
                    TableRelation = "Item Category";
                    ToolTip = 'Specifies the value of the Item Category field';
                }
                field(UnitPrice; TmpUnitPrice)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Unit Price';
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                group(Control6014409)
                {
                    ShowCaption = false;
                    field(StartDate; TmpStartDate)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the value of the Start Date field';
                    }
                    field(UntilDate; TmpUntilDate)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Until Date';
                        ToolTip = 'Specifies the value of the Until Date field';
                    }
                }
            }
            part(Schedules; "NPR TM Ticket Schedule Wizard")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Schedules';
            }
            group(Advanced)
            {
                Caption = 'Advanced';
                group(TicketType)
                {
                    Caption = 'Ticket Type';
                    field(TicketTypeDescription; TmpTicketTypeDescription)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Description';
                        Editable = NOT (TicketTypeCodeValid);
                        ToolTip = 'Specifies the value of the Description field';
                    }
                    field(TmpTicketTypeTemplate; TmpTicketTypeTemplate)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Ticket Type Template Code';
                        Importance = Additional;
                        TableRelation = "Config. Template Header" WHERE("Table ID" = CONST(6059784));
                        ToolTip = 'Specifies the value of the Ticket Type Template Code field';
                    }
                }
                group(Admission)
                {
                    Caption = 'Admission';
                    field(AdmissionCode; TmpAdmissionCode)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Code';
                        TableRelation = "NPR TM Admission"."Admission Code";
                        ToolTip = 'Specifies the value of the Code field';

                        trigger OnValidate()
                        begin
                            ValidateAdmissionCode();
                        end;
                    }
                    field(AdmissionDescription; TmpAdmissionDescription)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Description';
                        Editable = NOT (AdmissionCodeValid);
                        ToolTip = 'Specifies the value of the Description field';
                    }
                    field(TmpAdmissionTemplate; TmpAdmissionTemplate)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Admission Template Code';
                        Importance = Additional;
                        TableRelation = "Config. Template Header" WHERE("Table ID" = CONST(6060120));
                        ToolTip = 'Specifies the value of the Admission Template Code field';
                    }
                }
                group(TicketBom)
                {
                    Caption = 'Ticket BOM';
                    field(TmpTicketBomTemplate; TmpTicketBomTemplate)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Ticket BOM Template Code';
                        Importance = Additional;
                        TableRelation = "Config. Template Header" WHERE("Table ID" = CONST(6060121));
                        ToolTip = 'Specifies the value of the Ticket BOM Template Code field';
                    }
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Config. Template List")
            {
                ToolTip = 'Navigate to Template List';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Config. Template List';
                Image = Template;
                RunObject = Page "Config. Template List";
                RunPageView = WHERE("Table ID" = FILTER(6059784 .. 6060130));

            }
        }
    }

    trigger OnInit()
    begin
        // Page runs on temporary records
        Rec.Code := 'WIZARD';
        Rec.Description := TITLE;
        Rec.Insert();
    end;

    trigger OnOpenPage()
    begin

        SetDefaults();

        ValidateItemNo();
        ValidateTicketTypeCode();
        ValidateAdmissionCode();

        CurrPage.Update(false);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
    begin

        if (CloseAction = ACTION::LookupOK) then begin
            if (TmpItemCategory = '') then
                Error(MUST_NOT_BE_BLANK, Item.FieldCaption("Item Category Code"));

            if (TmpDescription = '') then
                Error(MUST_NOT_BE_BLANK, Item.FieldCaption(Description));

            if (TmpTicketTypeCode = '') then
                Error(MUST_NOT_BE_BLANK, TicketType.FieldCaption(Code));

        end;

        exit(true);
    end;

    var
        TmpDescription: Text[30];
        TmpStartDate: Date;
        TmpUntilDate: Date;
        TmpTicketTypeCode: Code[10];
        TmpTicketTypeDescription: Text[30];
        TmpTicketTypeTemplate: Code[10];
        TmpAdmissionCode: Code[20];
        TmpAdmissionDescription: Text[30];
        TmpAdmissionTemplate: Code[10];
        TmpTicketBomTemplate: Code[10];
        TicketTypeCodeValid: Boolean;
        AdmissionCodeValid: Boolean;
        TmpItemCategory: Code[20];
        TmpItemNo: Code[20];
        TmpUnitPrice: Decimal;
        ItemNumberValid: Boolean;
        MUST_NOT_BE_BLANK: Label '%1  must not be blank.';
        TITLE: Label 'Ticket Setup';

    local procedure SetDefaults()
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin

        TmpStartDate := Today();
        TicketSetup.Get();

        TmpAdmissionTemplate := TicketSetup."Wizard Admission Template";
        TmpTicketTypeTemplate := TicketSetup."Wizard Ticket Type Template";
        TmpTicketBomTemplate := TicketSetup."Wizard Ticket Bom Template";
    end;

    local procedure ValidateTicketTypeCode()
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        TicketSetup.Get();

        if (TmpTicketTypeCode = '') then begin
            TmpTicketTypeDescription := TmpDescription;
        end;

        TicketTypeCodeValid := TicketType.Get(TmpTicketTypeCode);
        if (TicketTypeCodeValid) then
            TmpTicketTypeDescription := TicketType.Description;
    end;

    local procedure ValidateAdmissionCode()
    var
        Admission: Record "NPR TM Admission";
    begin
        if (TmpAdmissionCode = '') then begin
            TmpAdmissionCode := '<GENERATE>';
            TmpAdmissionDescription := TmpDescription;
        end;

        AdmissionCodeValid := Admission.Get(TmpAdmissionCode);
        if (AdmissionCodeValid) then
            TmpAdmissionDescription := Admission.Description;
    end;

    local procedure ValidateItemNo()
    var
        Item: Record Item;
    begin
        if (TmpItemNo = '') then begin
            TmpItemNo := '<GENERATE>';
        end;

        ItemNumberValid := Item.Get(TmpItemNo);
        if (ItemNumberValid) then begin
            TmpDescription := Item.Description;
            TmpItemCategory := Item."Item Category Code";
            TmpUnitPrice := Item."Unit Price";

            TmpTicketTypeCode := Item."NPR Ticket Type";
            ValidateTicketTypeCode();
        end;
    end;

    procedure GetItemInformation(var ItemNumberOut: Code[20]; var DescriptionOut: Text[30]; var ItemCategoryOut: Code[20]; var UnitPriceOut: Decimal; var TicketBomTemplateOut: Code[10])
    begin

        ItemNumberOut := TmpItemNo;
        DescriptionOut := TmpDescription;
        ItemCategoryOut := TmpItemCategory;
        UnitPriceOut := TmpUnitPrice;
        TicketBomTemplateOut := TmpTicketBomTemplate;
    end;

    procedure GetScheduleInformation(var StartDateOut: Date; var UntilDateOut: Date; var AdmissionScheduleOut: Record "NPR TM Admis. Schedule" temporary)
    begin

        StartDateOut := TmpStartDate;
        UntilDateOut := TmpUntilDate;
        CurrPage.Schedules.PAGE.GetSchedules(AdmissionScheduleOut);
    end;

    procedure GetAdmissionInformation(var AdmissionCodeOut: Code[20]; var DescriptionOut: Text[30]; var AdmissionTemplateCodeOut: Code[10])
    begin

        AdmissionCodeOut := TmpAdmissionCode;
        DescriptionOut := TmpAdmissionDescription;
        AdmissionTemplateCodeOut := TmpAdmissionTemplate;
    end;

    procedure GetTicketTypeInformation(var TicketTypeOut: Code[10]; var DescriptionOut: Text[30]; var TicketTypeTemplateOut: Code[10])
    begin

        TicketTypeOut := TmpTicketTypeCode;
        DescriptionOut := TmpTicketTypeDescription;
        TicketTypeTemplateOut := TmpTicketTypeTemplate;
    end;
}

