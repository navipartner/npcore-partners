﻿codeunit 6151133 "NPR TM Ticket Wizard"
{
    Access = Internal;
    trigger OnRun()
    var
        ItemNumberCreated: Code[20];
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        TicketBOMPage: Page "NPR TM Ticket BOM";
    begin

        // Running codeunit from rolecenter to start wizard
        WizardSetup();
        Commit();

        if (not TicketWizard(ItemNumberCreated)) then
            exit;

        Commit();
        TicketBOM.SetFilter("Item No.", '=%1', ItemNumberCreated);
        TicketBOMPage.SetTableView(TicketBOM);
        TicketBOMPage.Run();
    end;

    procedure TicketWizard(var ItemNoOut: Code[20]): Boolean
    var
        AdmissionSchManagement: Codeunit "NPR TM Admission Sch. Mgt.";
        TicketWizardPage: Page "NPR TM Ticket Wizard";
        PageAction: Action;
        ItemNo: Code[20];
        ItemDescription: Text[30];
        ItemCategory: Code[20];
        UnitPrice: Decimal;
        TypeCode: Code[10];
        TypeDescription: Text[30];
        TypeTemplate: Code[10];
        AdmissionCode: Code[20];
        AdmissionDescription: Text[50];
        AdmissionTemplate: Code[10];
        ScheduleStartDate: Date;
        ScheduleUntilDate: Date;
        TempSchedules: Record "NPR TM Admis. Schedule" temporary;
        BomTemplate: Code[10];
    begin

        TicketWizardPage.LookupMode(true);
        TicketWizardPage.Editable(true);

        PageAction := TicketWizardPage.RunModal();
        if (PageAction <> ACTION::LookupOK) then
            exit(false);

        TicketWizardPage.GetTicketTypeInformation(TypeCode, TypeDescription, TypeTemplate);
        TicketWizardPage.GetItemInformation(ItemNo, ItemDescription, ItemCategory, UnitPrice, BomTemplate);
        TicketWizardPage.GetAdmissionInformation(AdmissionCode, AdmissionDescription, AdmissionTemplate);
        TicketWizardPage.GetScheduleInformation(ScheduleStartDate, ScheduleUntilDate, TempSchedules);

        CreateTicketType(TypeCode, TypeDescription, TypeTemplate);
        CreateItem(ItemNo, ItemDescription, ItemCategory, UnitPrice, TypeCode);
        CreateAdmission(AdmissionCode, AdmissionDescription, AdmissionTemplate);
        CreateSchedules(AdmissionCode, ScheduleStartDate, ScheduleUntilDate, TempSchedules);
        CreateTicketBom(ItemNo, AdmissionCode, BomTemplate);

        AdmissionSchManagement.CreateAdmissionSchedule(AdmissionCode, false, Today);

        ItemNoOut := ItemNo;
        exit(true);
    end;

    procedure WizardSetup()
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin

        if not (TicketSetup.Get()) then
            TicketSetup.Insert();

        if (TicketSetup."Wizard Item No. Series" = '') then
            TicketSetup."Wizard Item No. Series" := CreateNumberSeries('NPR-TM-ITM', 'TI-00001', 'Item');

        if (TicketSetup."Wizard Adm. Code No. Series" = '') then
            TicketSetup."Wizard Adm. Code No. Series" := CreateNumberSeries('NPR-TM-ADM', 'AD-00001', 'Admission');

        if (TicketSetup."Wizard Sch. Code No. Series" = '') then
            TicketSetup."Wizard Sch. Code No. Series" := CreateNumberSeries('NPR-TM-SCH', 'SC-00001', 'Schedule');

        if (TicketSetup."Wizard Ticket Type No. Series" = '') then
            TicketSetup."Wizard Ticket Type No. Series" := CreateNumberSeries('NPR-TM-TTN', 'TT-00001', 'Ticket Type');

        TicketSetup."Wizard Ticket Type Template" := CreateTicketTypeTemplate(TicketSetup."Wizard Ticket Type Template");
        TicketSetup."Wizard Admission Template" := CreateAdmissionTemplate(TicketSetup."Wizard Admission Template");
        TicketSetup."Wizard Ticket Bom Template" := CreateTicketBomTemplate(TicketSetup."Wizard Ticket Bom Template");

        TicketSetup.Modify();
    end;

    procedure CreateNumberSeries(NoSerieCode: Code[20]; StartNumber: Code[20]; TypeDescription: Text[20]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesDescriptionLbl: Label 'NPR Ticket Wizard (%1)';
    begin

        if (NoSeries.Get(NoSerieCode)) then
            exit(NoSerieCode);

        NoSeries.Code := NoSerieCode;
        NoSeries.Insert();

        NoSeries.Description := StrSubstNo(NoSeriesDescriptionLbl, TypeDescription);
        NoSeries."Default Nos." := true;
        NoSeries.Modify();

        if (not NoSeriesLine.Get(NoSerieCode, 10000)) then begin
            NoSeriesLine."Series Code" := NoSerieCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting Date" := 20160101D;
            NoSeriesLine."Starting No." := StartNumber;
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert();
        end;

        exit(NoSerieCode);
    end;

    local procedure CreateTicketType(var TypeCode: Code[10]; TypeDescription: Text[30]; TypeTemplateCode: Code[10])
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketType: Record "NPR TM Ticket Type";
        ConfigTemplateHeader: Record "Config. Template Header";
        RecRef: RecordRef;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        TypeCodeGenerated: Code[20];
    begin

        if (TicketType.Get(TypeCode)) then
            exit;

        TicketSetup.Get();
        if (TypeCode = '<GENERATE>') then begin
            TypeCodeGenerated := GetNextNo(TicketSetup."Wizard Ticket Type No. Series");
            if StrLen(TypeCodeGenerated) > 10 then
                TypeCode := CopyStr(TypeCodeGenerated, StrLen(TypeCode) - 10, 10)
            else
                TypeCode := CopyStr(TypeCode, 1, 10);
        end;

        TicketType.Code := TypeCode;
        TicketType.Insert(true);

        if (TypeTemplateCode <> '') then begin
            ConfigTemplateHeader.Get(TypeTemplateCode);
            RecRef.GetTable(TicketType);
            ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
            RecRef.SetTable(TicketType);
        end;

        if (TypeDescription <> '') then
            TicketType.Description := TypeDescription;

        TicketType.Modify(true);
    end;

    local procedure CreateAdmission(var AdmissionCode: Code[20]; Description: Text[50]; AdmissionTemplateCode: Code[10])
    var
        Admission: Record "NPR TM Admission";
        TicketSetup: Record "NPR TM Ticket Setup";
        ConfigTemplateHeader: Record "Config. Template Header";
        RecRef: RecordRef;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
    begin

        if (Admission.Get(AdmissionCode)) then
            exit;

        TicketSetup.Get();
        if (AdmissionCode = '<GENERATE>') then
            AdmissionCode := GetNextNo(TicketSetup."Wizard Adm. Code No. Series");

        Admission."Admission Code" := AdmissionCode;
        Admission.Insert(true);

        if (AdmissionTemplateCode <> '') then begin
            ConfigTemplateHeader.Get(AdmissionTemplateCode);
            RecRef.GetTable(Admission);
            ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
            RecRef.SetTable(Admission);
        end;

        if (Description <> '') then
            Admission.Description := Description;

        Admission.Modify();
    end;

    local procedure CreateSchedules(AdmissionCode: Code[20]; StartDate: Date; UntilDate: Date; var TmpSchedules: Record "NPR TM Admis. Schedule" temporary)
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLines: Record "NPR TM Admis. Schedule Lines";
        AdmissionScheduleDescriptionLbl: Label '%1 [%2 - %3]', Locked = true;
    begin

        if (TmpSchedules.IsEmpty()) then
            exit;

        TicketSetup.Get();
        TmpSchedules.FindSet();
        repeat

            AdmissionSchedule.Init();
            AdmissionSchedule.TransferFields(TmpSchedules, false);
            AdmissionSchedule.Description := StrSubstNo(AdmissionScheduleDescriptionLbl, AdmissionCode, TmpSchedules."Start Time", TmpSchedules."Stop Time");
            AdmissionSchedule."Schedule Type" := AdmissionSchedule."Schedule Type"::"EVENT";
            AdmissionSchedule."Admission Is" := AdmissionSchedule."Admission Is"::OPEN;

            AdmissionSchedule."Schedule Code" := GetNextNo(TicketSetup."Wizard Sch. Code No. Series");
            AdmissionSchedule."Start From" := StartDate;

            AdmissionSchedule."Recurrence Until Pattern" := AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE;
            if (UntilDate <> 0D) then begin
                AdmissionSchedule."End After Date" := UntilDate;
                AdmissionSchedule."Recurrence Until Pattern" := AdmissionSchedule."Recurrence Until Pattern"::END_DATE;
            end;

            AdmissionSchedule."Recur Every N On" := 1;
            AdmissionSchedule."Recurrence Pattern" := AdmissionSchedule."Recurrence Pattern"::WEEKLY;
            AdmissionSchedule.Insert();

            ScheduleLines.Init();
            ScheduleLines.Validate("Admission Code", AdmissionCode);
            ScheduleLines.Validate("Schedule Code", AdmissionSchedule."Schedule Code");
            ScheduleLines.Insert(true);

        until (TmpSchedules.Next() = 0);
    end;

    local procedure CreateTicketBom(ItemNo: Code[20]; AdmissionCode: Code[20]; TicketBomTemplate: Code[10])
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        ConfigTemplateHeader: Record "Config. Template Header";
        RecRef: RecordRef;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        TempTicketBom: Record "NPR TM Ticket Admission BOM" temporary;
    begin

        TicketSetup.Get();
        TicketBOM.Init();

        // For some reason, template attempts to fill value of for part of key that is blank.
        TempTicketBom."Item No." := ItemNo;
        TempTicketBom."Variant Code" := 'X'; // Dummy value to fool template management updaterecord function
        TempTicketBom."Admission Code" := AdmissionCode;
        TempTicketBom.Insert(true);

        if (TicketBomTemplate <> '') then begin
            ConfigTemplateHeader.Get(TicketBomTemplate);
            RecRef.GetTable(TempTicketBom);
            ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
            RecRef.SetTable(TempTicketBom);
        end;
        TempTicketBom.Modify();

        // Create persistant record
        TicketBOM.Init();
        TicketBOM.Validate("Item No.", ItemNo);
        TicketBOM.Validate("Admission Code", AdmissionCode);
        TicketBOM.Insert();
        TicketBOM.TransferFields(TempTicketBom, false);
        TicketBOM.Validate("Item No.", ItemNo);
        TicketBOM.Validate("Admission Code", AdmissionCode);
        TicketBOM.Default := true;
        TicketBOM.Modify();
    end;

    local procedure CreateTicketTypeTemplate(TemplateCode: Code[10]): Code[10]
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        TicketType: Record "NPR TM Ticket Type";
    begin

        if (ConfigTemplateHeader.Get(TemplateCode)) then
            exit(TemplateCode);

        TemplateCode := 'TM-TTYPE';
        if (not ConfigTemplateHeader.Get(TemplateCode)) then begin
            ConfigTemplateHeader.Init();
            ConfigTemplateHeader.Code := TemplateCode;
            ConfigTemplateHeader.Description := 'Ticket Type Wizard Template';
            ConfigTemplateHeader.Validate("Table ID", DATABASE::"NPR TM Ticket Type");
            ConfigTemplateHeader.Insert(true);
        end;

        ConfigTemplateLine.SetFilter("Data Template Code", '=%1', ConfigTemplateHeader.Code);
        ConfigTemplateLine.DeleteAll();

        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_BOM;
        TicketType."Activation Method" := TicketType."Activation Method"::SCAN;
        TicketType."Ticket Entry Validation" := TicketType."Ticket Entry Validation"::SAME_DAY;

        AddConfigTemplateLine(TemplateCode, 0, TicketType.FieldNo("External Ticket Pattern"), '[S][A*4]-[N]');
        AddConfigTemplateLine(TemplateCode, 0, TicketType.FieldNo("No. Series"), CreateNumberSeries('NPR-TM-TIC', 'T0000001', 'Ticket'));
        AddConfigTemplateLine(TemplateCode, 0, TicketType.FieldNo("Ticket Configuration Source"), Format(TicketType."Ticket Configuration Source"));
        AddConfigTemplateLine(TemplateCode, 0, TicketType.FieldNo("Activation Method"), Format(TicketType."Activation Method"));
        AddConfigTemplateLine(TemplateCode, 0, TicketType.FieldNo("Ticket Entry Validation"), Format(TicketType."Ticket Entry Validation"));

        exit(ConfigTemplateHeader.Code);
    end;

    local procedure CreateAdmissionTemplate(TemplateCode: Code[10]): Code[10]
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        Admission: Record "NPR TM Admission";
    begin

        if (ConfigTemplateHeader.Get(TemplateCode)) then
            exit(TemplateCode);

        TemplateCode := 'TM-ADMSN';
        if (not ConfigTemplateHeader.Get(TemplateCode)) then begin
            ConfigTemplateHeader.Init();
            ConfigTemplateHeader.Code := TemplateCode;
            ConfigTemplateHeader.Description := 'Admission Wizard Template';
            ConfigTemplateHeader.Validate("Table ID", DATABASE::"NPR TM Admission");
            ConfigTemplateHeader.Insert(true);
        end;

        ConfigTemplateLine.SetFilter("Data Template Code", '=%1', ConfigTemplateHeader.Code);
        ConfigTemplateLine.DeleteAll();

        Admission.Type := Admission.Type::OCCASION;
        Admission."Capacity Limits By" := Admission."Capacity Limits By"::SCHEDULE;
        Admission."Default Schedule" := Admission."Default Schedule"::NEXT_AVAILABLE;
        Admission."Capacity Control" := Admission."Capacity Control"::NONE;

        AddConfigTemplateLine(TemplateCode, 0, Admission.FieldNo(Type), Format(Admission.Type));
        AddConfigTemplateLine(TemplateCode, 0, Admission.FieldNo("Capacity Limits By"), Format(Admission."Capacity Limits By"));
        AddConfigTemplateLine(TemplateCode, 0, Admission.FieldNo("Default Schedule"), Format(Admission."Default Schedule"));
        AddConfigTemplateLine(TemplateCode, 0, Admission.FieldNo("Capacity Control"), Format(Admission."Capacity Control"));

        exit(ConfigTemplateHeader.Code);
    end;

    local procedure CreateTicketBomTemplate(TemplateCode: Code[10]): Code[10]
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
    begin

        if (ConfigTemplateHeader.Get(TemplateCode)) then
            exit(TemplateCode);

        TemplateCode := 'TM-TCBOM ';
        if (not ConfigTemplateHeader.Get(TemplateCode)) then begin
            ConfigTemplateHeader.Init();
            ConfigTemplateHeader.Code := TemplateCode;
            ConfigTemplateHeader.Description := 'Ticket BOM Wizard Template';
            ConfigTemplateHeader.Validate("Table ID", DATABASE::"NPR TM Ticket Admission BOM");
            ConfigTemplateHeader.Insert(true);
        end;

        ConfigTemplateLine.SetFilter("Data Template Code", '=%1', ConfigTemplateHeader.Code);
        ConfigTemplateLine.DeleteAll();

        TicketBOM."Admission Entry Validation" := TicketBOM."Admission Entry Validation"::SAME_DAY;
        TicketBOM."Activation Method" := TicketBOM."Activation Method"::SCAN;
        TicketBOM."Revisit Condition (Statistics)" := TicketBOM."Revisit Condition (Statistics)"::DAILY_NONINITIAL;
        Evaluate(TicketBOM."Duration Formula", '<12M>');

        AddConfigTemplateLine(TemplateCode, 0, TicketBOM.FieldNo("Admission Entry Validation"), Format(TicketBOM."Admission Entry Validation"));
        AddConfigTemplateLine(TemplateCode, 0, TicketBOM.FieldNo("Activation Method"), Format(TicketBOM."Activation Method"));
        AddConfigTemplateLine(TemplateCode, 0, TicketBOM.FieldNo("Revisit Condition (Statistics)"), Format(TicketBOM."Revisit Condition (Statistics)"));
        AddConfigTemplateLine(TemplateCode, 0, TicketBOM.FieldNo("Duration Formula"), Format(TicketBOM."Duration Formula"));

        exit(ConfigTemplateHeader.Code);
    end;

    local procedure CreateItem(var ItemNo: Code[20]; ItemDescription: Text[50]; ItemCategory: Code[20]; UnitPrice: Decimal; TicketType: Code[10])
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        Item: Record Item;
        AuxItem: Record "NPR Aux Item";
    begin

        if (Item.Get(ItemNo)) then
            exit;

        TicketSetup.Get();
        if (ItemNo = '<GENERATE>') then
            ItemNo := GetNextNo(TicketSetup."Wizard Item No. Series");

        Item.Validate("No.", ItemNo);
        Item.Insert(true);

        Item.Validate(Description, ItemDescription);
        Item.Validate("Item Category Code", ItemCategory);
        Item.Validate("Unit Price", UnitPrice);
        Item.NPR_GetAuxItem(AuxItem);
        AuxItem.Validate("TM Ticket Type", TicketType);
        Item.NPR_SetAuxItem(AuxItem);
        Item.NPR_SaveAuxItem();

        Item.TestField(Description);
        Item.TestField("Item Category Code");
        AuxItem.TestField("TM Ticket Type");

        Item.Modify(true);
    end;

    local procedure GetNextNo(NoSeries: Code[20]): Code[20]
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin

        exit(NoSeriesManagement.GetNextNo(NoSeries, Today, true));
    end;

    local procedure AddConfigTemplateLine(TemplateCode: Code[10]; LineNo: Integer; FieldId: Integer; Value: Text[250]): Integer
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
    begin

        ConfigTemplateHeader.Get(TemplateCode);

        if (LineNo = 0) then begin
            ConfigTemplateLine.SetFilter("Data Template Code", '=%1', TemplateCode);
            LineNo := 1000;
            if (ConfigTemplateLine.FindLast()) then
                LineNo += ConfigTemplateLine."Line No.";
        end;

        if (not ConfigTemplateLine.Get(TemplateCode, LineNo)) then begin
            ConfigTemplateLine.Init();
            ConfigTemplateLine."Data Template Code" := TemplateCode;
            ConfigTemplateLine."Line No." := LineNo;
            ConfigTemplateLine.Insert(true);
        end;

        ConfigTemplateLine.Type := ConfigTemplateLine.Type::Field;
        ConfigTemplateLine."Skip Relation Check" := true; // Avoid COMMIT when validating default value

        ConfigTemplateLine.Validate("Language ID", 1033);
        ConfigTemplateLine.Validate("Table ID", ConfigTemplateHeader."Table ID");
        ConfigTemplateLine.Validate("Field ID", FieldId);
        ConfigTemplateLine.Validate("Default Value", Value);
        ConfigTemplateLine.Modify(true);

        exit(LineNo);
    end;
}

