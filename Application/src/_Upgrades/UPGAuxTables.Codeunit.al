codeunit 6014436 "NPR UPG Aux Tables"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Aux Table Fields', 'OnUpgradePerCompany');
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Aux Tables")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpdateTableExtensionFieldsToRelationTable();
        UpdateNpXmlReferences();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Aux Tables"));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateTableExtensionFieldsToRelationTable()
    begin
        UpgradeItemAddOnNoToRelationTable();
        UpgradeVarietyGroupToRelationTable();
        UpgradeItemStatusToRelationTable();
        UpgradeAttributeSetIDToRelationTable();
        UpgradeMagentoBrandToRelationTable();
        UpgradeTicketTypeToRelationTable();
        UpgradeRestItemRoutingProfileToRelationTable();
        UpgradeVariety1TableToRelationTable();
        UpgradeVariety2TableToRelationTable();
        UpgradeVariety3TableToRelationTable();
        UpgradeVariety4TableToRelationTable();
        UpgradeVariety1ToRelationTable();
        UpgradeVariety2ToRelationTable();
        UpgradeVariety3ToRelationTable();
        UpgradeVariety4ToRelationTable();
        UpgradeHasAccessoriesToRelationTable();
    end;

    local procedure UpdateNpXmlReferences()
    begin
        UpdateAuxItemNpXmlReferences();
    end;

    local procedure UpdateAuxItemNpXmlReferences()
    var
        AuxTableFields: Record Field;
        ItemTableFields: Record Field;
        NPRNpXmlTemplate: Record "NPR NpXml Template";
        NPRNpXmlElement: Record "NPR NpXml Element";
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        AuxTablesMgt: Codeunit "NPR Aux. Tables Mgt.";
    begin
        AuxTableFields.SetRange(TableNo, AuxTablesMgt.GetAuxTableIdFromParentTable(Database::Item));
        AuxTableFields.SetFilter("No.", '>%1', 1);
        if not AuxTableFields.FindSet() then
            exit;
        repeat
            ItemTableFields.SetRange(TableNo, Database::Item);
            if (AuxTableFields.FieldName.StartsWith('NPR ')) then
                ItemTableFields.SetRange(FieldName, AuxTableFields.FieldName)
            else
                ItemTableFields.SetRange(FieldName, 'NPR ' + AuxTableFields.FieldName);
            if ItemTableFields.FindFirst() then begin
                //Updating References in XML Template
                //XML Element
                UpgradeFieldReferencesToXMLElement(Database::Item, ItemTableFields."No.", AuxTablesMgt.GetAuxTableIdFromParentTable(Database::Item), AuxTableFields."No.");

                //XML Filter
                UpgradeFieldReferencesToXMLFilter(Database::Item, ItemTableFields."No.", AuxTablesMgt.GetAuxTableIdFromParentTable(Database::Item), AuxTableFields."No.");

                //XML Attribute
                UpgradeFieldReferencesToXMLAttribute(Database::Item, ItemTableFields."No.", AuxTablesMgt.GetAuxTableIdFromParentTable(Database::Item), AuxTableFields."No.");
            end;
        until AuxTableFields.Next() = 0;
        if NPRNpXmlTemplate.IsEmpty() then
            exit;
        NPRNpXmlTemplate.FindSet();
        repeat
            NPRNpXmlElement.SetRange("Xml Template Code", NPRNpXmlTemplate.Code);
            if NPRNpXmlElement.FindFirst() then
                NpXmlTemplateMgt.NormalizeNpXmlElementLineNo(NPRNpXmlElement."Xml Template Code", NPRNpXmlElement);
        until NPRNpXmlTemplate.Next() = 0;
    end;

    local procedure UpgradeFieldReferencesToXMLElement(FromTableNo: Integer; FromFieldNo: Integer; ToTableNo: Integer; ToFieldNo: Integer)
    var
        NPRNpXmlElement: Record "NPR NpXml Element";
        NPRNpXmlElement2: Record "NPR NpXml Element";
    begin
        if NPRNpXmlElement.IsEmpty() then
            exit;

        NPRNpXmlElement.SetLoadFields("Table No.", "Field No.", Level);
        NPRNpXmlElement.SetRange("Table No.", FromTableNo);
        NPRNpXmlElement.SetRange("Field No.", FromFieldNo);
        if NPRNpXmlElement.FindFirst() then begin
            InsertNewParentElement(NPRNpXmlElement, ToTableNo);
            NPRNpXmlElement."Table No." := ToTableNo;
            NPRNpXmlElement.Level += 1;
            NPRNpXmlElement.Modify();
            IncreaseChildElementsLevel(NPRNpXmlElement);
            NPRNpXmlElement2.SetRange("Table No.", FromTableNo);
            NPRNpXmlElement2.SetRange("Field No.", FromFieldNo);
            NPRNpXmlElement2.ModifyAll("Table No.", ToTableNo);
            NPRNpXmlElement2.SetRange("Table No.", ToTableNo);
            NPRNpXmlElement2.ModifyAll("Field No.", ToFieldNo);
        end;
    end;

    local procedure InsertNewParentElement(NPRNpXmlElement: Record "NPR NpXml Element"; ToTableNo: Integer)
    var
        NpXmlElement: Record "NPR NpXml Element";
        ElementNameLbl: Label 'auxitem_buffer', Locked = true;
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
    begin
        NpXmlTemplateMgt.InitNpXmlElementAbove(NPRNpXmlElement."Xml Template Code", NPRNpXmlElement."Line No.", NpXmlElement);

        NpXmlElement.Level := NPRNpXmlElement.Level;
        if NpXmlElement.Level < 0 then
            NpXmlElement.Level := 0;
        NpXmlElement."Table No." := ToTableNo;
        NpXmlElement.Hidden := true;
        NpXmlElement."Element Name" := ElementNameLbl;
        NpXmlElement.Insert(true);
        InsertAuxRelations(NpXmlElement);
    end;

    local procedure UpgradeFieldReferencesToXMLFilter(FromTableNo: Integer; FromFieldNo: Integer; ToTableNo: Integer; ToFieldNo: Integer)
    var
        NPRNpXmlFilter: Record "NPR NpXml Filter";
        NPRNpXmlFilter2: Record "NPR NpXml Filter";
        NPRNpXmlElement: Record "NPR NpXml Element";
    begin
        if NPRNpXmlFilter.IsEmpty() then
            exit;

        NPRNpXmlFilter.SetLoadFields("Parent Table No.", "Parent Field No.");
        NPRNpXmlFilter.SetRange("Parent Table No.", FromTableNo);
        NPRNpXmlFilter.SetRange("Parent Field No.", FromFieldNo);
        if NPRNpXmlFilter.FindFirst() then begin
            NPRNpXmlElement.Get(NPRNpXmlFilter."Xml Template Code", NPRNpXmlFilter."Xml Element Line No.");
            InsertNewParentElement(NPRNpXmlElement, ToTableNo);
            NPRNpXmlElement.Level += 1;
            NPRNpXmlElement.Modify();
            NPRNpXmlElement.Level -= 1;
            IncreaseChildElementsLevel(NPRNpXmlElement);
            NPRNpXmlFilter2.SetRange("Parent Table No.", FromTableNo);
            NPRNpXmlFilter2.SetRange("Parent Field No.", FromFieldNo);
            NPRNpXmlFilter2.ModifyAll("Parent Table No.", ToTableNo);
            NPRNpXmlFilter2.SetRange("Parent Table No.", ToTableNo);
            NPRNpXmlFilter2.ModifyAll("Parent Field No.", ToFieldNo);
        end;
        Clear(NPRNpXmlFilter);
        NPRNpXmlFilter.SetLoadFields("Table No.", "Field No.");
        NPRNpXmlFilter.SetRange("Table No.", FromTableNo);
        NPRNpXmlFilter.SetRange("Field No.", FromFieldNo);
        if NPRNpXmlFilter.FindFirst() then begin
            NPRNpXmlElement.Get(NPRNpXmlFilter."Xml Template Code", NPRNpXmlFilter."Line No.");
            InsertNewParentElement(NPRNpXmlElement, ToTableNo);
            NPRNpXmlElement.Level += 1;
            NPRNpXmlElement.Modify();
            NPRNpXmlElement.Level -= 1;
            IncreaseChildElementsLevel(NPRNpXmlElement);
            NPRNpXmlFilter2.SetRange("Parent Table No.", FromTableNo);
            NPRNpXmlFilter2.SetRange("Parent Field No.", FromFieldNo);
            NPRNpXmlFilter2.ModifyAll("Parent Table No.", ToTableNo);
            NPRNpXmlFilter2.SetRange("Parent Table No.", ToTableNo);
            NPRNpXmlFilter2.ModifyAll("Parent Field No.", ToFieldNo);
        end;
    end;

    local procedure UpgradeFieldReferencesToXMLAttribute(FromTableNo: Integer; FromFieldNo: Integer; ToTableNo: Integer; ToFieldNo: Integer)
    var
        NPRNpXmlAttribute: Record "NPR NpXml Attribute";
    begin
        if NPRNpXmlAttribute.IsEmpty() then
            exit;

        NPRNpXmlAttribute.SetLoadFields("Table No.", "Attribute Field No.");
        NPRNpXmlAttribute.SetRange("Table No.", FromTableNo);
        NPRNpXmlAttribute.SetRange("Attribute Field No.", FromFieldNo);
        if not NPRNpXmlAttribute.IsEmpty() then begin
            NPRNpXmlAttribute.ModifyAll("Table No.", ToTableNo);
            NPRNpXmlAttribute.SetRange("Table No.", ToTableNo);
            NPRNpXmlAttribute.ModifyAll("Attribute Field No.", ToFieldNo);
        end;
    end;

    procedure InsertAuxRelations(SelectedNpXmlElement: Record "NPR NpXml Element")
    var
        "Field": Record "Field";
        NpXmlElement: Record "NPR NpXml Element";
        NpXmlFilter: Record "NPR NpXml Filter";
        TempField: Record "Field" temporary;
        TableMetadata: Record "Table Metadata";
        RecRef: RecordRef;
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        LineNo: Integer;
        i: Integer;
    begin
        if not TableMetadata.Get(SelectedNpXmlElement."Table No.") then
            exit;

        NpXmlElement := SelectedNpXmlElement;
        NpXmlElement.SetRange("Xml Template Code", SelectedNpXmlElement."Xml Template Code");
        repeat
            if NpXmlElement.Next(-1) = 0 then
                exit;
        until NpXmlElement.Level + 1 = SelectedNpXmlElement.Level;

        if NpXmlElement."Table No." = SelectedNpXmlElement."Table No." then
            exit;
        if not TableMetadata.Get(NpXmlElement."Table No.") then
            exit;

        RecRef.Open(SelectedNpXmlElement."Table No.");
        KeyRef := RecRef.KeyIndex(1);
        RecRef.Close();
        for i := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(i);

            Field.Get(SelectedNpXmlElement."Table No.", FieldRef.Number);
            if Field.RelationTableNo = NpXmlElement."Table No." then begin
                TempField.Init();
                TempField := Field;
                TempField.Insert();
            end;
        end;

        if not TempField.FindSet() then
            exit;

        NpXmlElement.CalcFields("Table Name");

        RecRef.Open(NpXmlElement."Table No.");
        KeyRef := RecRef.KeyIndex(1);
        RecRef.Close();
        FieldRef := KeyRef.FieldIndex(1);

        NpXmlFilter.SetRange("Xml Template Code", SelectedNpXmlElement."Xml Template Code");
        NpXmlFilter.SetRange("Xml Element Line No.", SelectedNpXmlElement."Line No.");
        NpXmlFilter.DeleteAll();
        LineNo := 0;
        repeat
            LineNo += 10000;
            NpXmlFilter.Init();
            NpXmlFilter."Xml Template Code" := SelectedNpXmlElement."Xml Template Code";
            NpXmlFilter."Xml Element Line No." := SelectedNpXmlElement."Line No.";
            NpXmlFilter."Line No." := LineNo;
            NpXmlFilter."Filter Type" := NpXmlFilter."Filter Type"::TableLink;
            NpXmlFilter."Parent Table No." := TempField.RelationTableNo;
            NpXmlFilter."Parent Field No." := TempField.RelationFieldNo;
            if NpXmlFilter."Parent Field No." = 0 then
                NpXmlFilter."Parent Field No." := FieldRef.Number;
            NpXmlFilter."Table No." := TempField.TableNo;
            NpXmlFilter."Field No." := TempField."No.";
            NpXmlFilter.Insert(true);
        until TempField.Next() = 0;
    end;

    procedure IncreaseChildElementsLevel(SelectedNpXmlElement: Record "NPR NpXml Element")
    var
        NPRNpXmlElement: Record "NPR NpXml Element";
        InitialLevel: Integer;
    begin
        InitialLevel := SelectedNpXmlElement.Level;
        NPRNpXmlElement.SetCurrentKey("Xml Template Code", "Line No.");
        NPRNpXmlElement.Ascending(true);
        NPRNpXmlElement.SetRange("Xml Template Code", SelectedNpXmlElement."Xml Template Code");
        NPRNpXmlElement.SetFilter("Line No.", '>%1', SelectedNpXmlElement."Line No.");
        NPRNpXmlElement.FindSet(true);
        repeat
            if (NPRNpXmlElement.Level > InitialLevel) then begin
                NPRNpXmlElement.Level += 1;
                NPRNpXmlElement.Modify();
            end else
                break;
        until NPRNpXmlElement.Next() = 0;
    end;

    local procedure UpgradeItemAddOnNoToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Item AddOn No.");
        FromMigrationRec.SetRange("NPR Item AddOn No.", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."Item Addon No." := FromMigrationRec."NPR Item AddOn No.";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeVarietyGroupToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Variety Group");
        FromMigrationRec.SetRange("NPR Variety Group", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."Variety Group" := FromMigrationRec."NPR Variety Group";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeItemStatusToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Item Status");
        FromMigrationRec.SetRange("NPR Item Status", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."Item Status" := FromMigrationRec."NPR Item Status";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeMagentoBrandToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Magento Brand");
        FromMigrationRec.SetRange("NPR Magento Brand", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."Magento Brand" := FromMigrationRec."NPR Magento Brand";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeAttributeSetIDToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Attribute Set ID");
        FromMigrationRec.SetFilter("NPR Attribute Set ID", '<>%1', 0);
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."Attribute Set ID" := FromMigrationRec."NPR Attribute Set ID";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeRestItemRoutingProfileToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR NPRE Item Routing Profile");
        FromMigrationRec.SetRange("NPR NPRE Item Routing Profile", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."NPRE Item Routing Profile" := FromMigrationRec."NPR NPRE Item Routing Profile";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeTicketTypeToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Ticket Type");
        FromMigrationRec.SetRange("NPR Ticket Type", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."TM Ticket Type" := FromMigrationRec."NPR Ticket Type";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeVariety1ToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Variety 1");
        FromMigrationRec.SetRange("NPR Variety 1", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."Variety 1" := FromMigrationRec."NPR Variety 1";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeVariety2ToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Variety 2");
        FromMigrationRec.SetRange("NPR Variety 2", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."Variety 2" := FromMigrationRec."NPR Variety 2";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeVariety3ToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Variety 3");
        FromMigrationRec.SetRange("NPR Variety 3", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."Variety 3" := FromMigrationRec."NPR Variety 3";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeVariety4ToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Variety 4");
        FromMigrationRec.SetRange("NPR Variety 4", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."Variety 4" := FromMigrationRec."NPR Variety 4";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeVariety1TableToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Variety 1 Table");
        FromMigrationRec.SetRange("NPR Variety 1 Table", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."Variety 1 Table" := FromMigrationRec."NPR Variety 1 Table";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeVariety2TableToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Variety 2 Table");
        FromMigrationRec.SetRange("NPR Variety 2 Table", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."Variety 2 Table" := FromMigrationRec."NPR Variety 2 Table";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeVariety3TableToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Variety 3 Table");
        FromMigrationRec.SetRange("NPR Variety 3 Table", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."Variety 3 Table" := FromMigrationRec."NPR Variety 3 Table";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeVariety4TableToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Aux Item";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("No.", "NPR Variety 4 Table");
        FromMigrationRec.SetRange("NPR Variety 4 Table", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec."Item No." := FromMigrationRec."No.";
                ToMigrationRec."Variety 4 Table" := FromMigrationRec."NPR Variety 4 Table";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    local procedure UpgradeHasAccessoriesToRelationTable()
    var
        FromMigrationRec: Record "NPR Accessory/Spare Part";
        AuxTablesMgt: Codeunit "NPR Aux. Tables Mgt.";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields(Code);
        if FromMigrationRec.FindSet() then
            repeat
                AuxTablesMgt.CreateAuxItemAccessoryLink(FromMigrationRec.Code, '', true);
            until FromMigrationRec.Next() = 0;
    end;
}
