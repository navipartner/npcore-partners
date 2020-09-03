page 6151133 "NPR TM Ticket Wizard"
{
    // TM90.1.46/TSA /20200320 CASE 397084 Initial Version

    Caption = 'Ticket Setup Wizard';
    DataCaptionExpression = Description;
    DataCaptionFields = Description;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "NPR TM Ticket Type";
    SourceTableTemporary = true;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(TicketTypeCode; TmpTicketTypeCode)
                {
                    ApplicationArea = All;
                    Caption = 'Code';
                    ShowMandatory = true;
                    TableRelation = "NPR TM Ticket Type".Code;

                    trigger OnValidate()
                    begin
                        ValidateTicketTypeCode();
                    end;
                }
                field(ItemNo; TmpItemNo)
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    TableRelation = Item;

                    trigger OnValidate()
                    begin
                        ValidateItemNo();
                    end;
                }
                field(Description; TmpDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = NOT (ItemNumberValid);
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if (not TicketTypeCodeValid) then
                            TmpTicketTypeDescription := TmpDescription;

                        if (not AdmissionCodeValid) then
                            TmpAdmissionDescription := TmpDescription;
                    end;
                }
                field(ItemGroup; TmpItemGroup)
                {
                    ApplicationArea = All;
                    Caption = 'Item Group';
                    Editable = NOT (ItemNumberValid);
                    ShowMandatory = true;
                    TableRelation = "NPR Item Group";
                }
                field(UnitPrice; TmpUnitPrice)
                {
                    ApplicationArea = All;
                    Caption = 'Unit Price';
                }
                group(Control6014409)
                {
                    ShowCaption = false;
                    field(StartDate; TmpStartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                    }
                    field(UntilDate; TmpUntilDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Until Date';
                    }
                }
            }
            part(Schedules; "NPR TM Ticket Schedule Wizard")
            {
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
                        ApplicationArea = All;
                        Caption = 'Description';
                        Editable = NOT (TicketTypeCodeValid);
                    }
                    field(TmpTicketTypeTemplate; TmpTicketTypeTemplate)
                    {
                        ApplicationArea = All;
                        Caption = 'Ticket Type Template Code';
                        Importance = Additional;
                        TableRelation = "Config. Template Header" WHERE("Table ID" = CONST(6059784));
                    }
                }
                group(Admission)
                {
                    Caption = 'Admission';
                    field(AdmissionCode; TmpAdmissionCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Code';
                        TableRelation = "NPR TM Admission"."Admission Code";

                        trigger OnValidate()
                        begin
                            ValidateAdmissionCode();
                        end;
                    }
                    field(AdmissionDescription; TmpAdmissionDescription)
                    {
                        ApplicationArea = All;
                        Caption = 'Description';
                        Editable = NOT (AdmissionCodeValid);
                    }
                    field(TmpAdmissionTemplate; TmpAdmissionTemplate)
                    {
                        ApplicationArea = All;
                        Caption = 'Admission Template Code';
                        Importance = Additional;
                        TableRelation = "Config. Template Header" WHERE("Table ID" = CONST(6060120));
                    }
                }
                group(TicketBom)
                {
                    Caption = 'Ticket BOM';
                    field(TmpTicketBomTemplate; TmpTicketBomTemplate)
                    {
                        ApplicationArea = All;
                        Caption = 'Ticket BOM Template Code';
                        Importance = Additional;
                        TableRelation = "Config. Template Header" WHERE("Table ID" = CONST(6060121));
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
                Caption = 'Config. Template List';
                Ellipsis = true;
                Image = Template;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
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
            if (TmpItemGroup = '') then
                Error(MUST_NOT_BE_BLANK, Item.FieldCaption("NPR Item Group"));

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
        TmpItemGroup: Code[10];
        TmpItemNo: Code[20];
        TmpUnitPrice: Decimal;
        ItemNumberValid: Boolean;
        MUST_NOT_BE_BLANK: Label '%1  must not be blank.';
        TITLE: Label 'Ticket Setup';

    local procedure SetDefaults()
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin

        TmpStartDate := Today;
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
            TmpItemGroup := Item."NPR Item Group";
            TmpUnitPrice := Item."Unit Price";

            TmpTicketTypeCode := Item."NPR Ticket Type";
            ValidateTicketTypeCode();
        end;
    end;

    procedure GetItemInformation(var ItemNumberOut: Code[20]; var DescriptionOut: Text[30]; var ItemGroupOut: Code[10]; var UnitPriceOut: Decimal; var TicketBomTemplateOut: Code[10])
    begin

        ItemNumberOut := TmpItemNo;
        DescriptionOut := TmpDescription;
        ItemGroupOut := TmpItemGroup;
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

