page 6151413 "Magento Item Picture List"
{
    // MAG1.02/MHA /20150202  CASE 199932 Object created - Contains a list of Color associated to an Item
    // MAG1.09/MHA /20150316  CASE 206395 Added Manual SetColorCode on SubPage
    // MAG1.21/MHA /20151104  CASE 223835 Changed functionality from Hardcoded Color to Variant Dimension Setup implementing Variety and VariaX without direct references
    //                                    SourceTable is temporary and Variant Dimension Value is buffered in Rec."Item No."
    // MAG1.22/MHA /20160426  CASE 239773 Change iteration on Item Variant during Setup of Variety Source Table
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.02/TS  /20170125  CASE 262261 Removed all reference to Variax

    Caption = 'Item Pictures';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SourceTable = "Item Variant";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control6150618)
            {
                ShowCaption = false;
                group(Variants)
                {
                    Caption = 'Variants';
                    Visible = HasVariants;
                    repeater(Group)
                    {
                        field("Item No.";"Item No.")
                        {
                            Editable = false;
                        }
                        field(Description;Description)
                        {
                            Editable = false;
                        }
                    }
                }
                part(MagentoPictureLinkSubform;"Magento Picture Link Subform")
                {
                    Caption = 'Pictures';
                    ShowFilter = false;
                }
            }
        }
        area(factboxes)
        {
            part(MagentoPictureDragDropAddin;"Magento DragDropPic. Addin")
            {
                Caption = 'Magento Picture';
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-MAG1.21
        ////-MAG1.09
        //CurrPage.MagentoPictureLinkSubform.PAGE.SetColorCode("Dim. Value Code");
        ////+MAG1.09
        CurrPage.MagentoPictureLinkSubform.PAGE.SetVariantValueCode("Item No.");
        CurrPage.MagentoPictureDragDropAddin.PAGE.SetVariantValueCode("Item No.");
        //+MAG1.21
    end;

    trigger OnOpenPage()
    begin
        //-MAG1.21
        //SetupItemColors();
        //CurrPage.MagentoPictureLinkSubform.PAGE.SetColorVisible(FALSE);
        CurrPage.MagentoPictureLinkSubform.PAGE.SetItemNoFilter(ItemNo);
        CurrPage.MagentoPictureDragDropAddin.PAGE.SetItemNo(ItemNo);
        CurrPage.MagentoPictureDragDropAddin.PAGE.SetHidePicture(true);
        SetupSourceTable();
        //+MAG1.21
    end;

    var
        MagentoSetup: Record "Magento Setup";
        GenericSetupMgt: Codeunit "Magento Generic Setup Mgt.";
        ItemNo: Code[20];
        Text000: Label 'Item No. must not be blank';
        HasVariants: Boolean;
        Text001: Label 'Main Item Pictures';

    procedure SetItemNo(NewItemNo: Code[20])
    begin
        ItemNo := NewItemNo;
    end;

    local procedure SetupSourceTable()
    begin
        //-MAG1.21
        //VariaXConfiguration.GET;
        //Item.GET(ItemNo);
        //
        //DELETEALL;
        //CLEAR(VariaXDimCom);
        //VariaXDimCom.SETRANGE("Dim No.",VariaXConfiguration."Color Dimension");
        //VariaXDimCom.SETRANGE("Item No.",ItemNo);
        //VariaXDimCom.SETRANGE(Disabled,FALSE);
        //IF VariaXDimCom.FINDSET THEN
        //  REPEAT
        //    IF NOT GET(VariaXDimCom."Dim No.",VariaXDimCom."Dim Value",ItemNo) THEN BEGIN
        //      VariaXDimValues.GET(VariaXDimCom."Dim No.",VariaXDimCom."Dim Value",VariaXDimCom."Dim Group");
        //      INIT;
        //      Rec := VariaXDimValues;
        //      "Parent Dim. Value Filter" := ItemNo;
        //      INSERT;
        //    END;
        //  UNTIL VariaXDimCom.NEXT = 0;
        MagentoSetup.Get;

        if ItemNo = '' then
          Error(Text000);

        HasVariants := false;
        Init;
        "Item No." := '';
        Code := '';
        Description := Text001;
        Insert;

        if not (MagentoSetup."Variant System" in [MagentoSetup."Variant System"::"1",MagentoSetup."Variant System"::Variety]) then
          exit;

        if MagentoSetup."Variant Picture Dimension" = '' then
          exit;

        case MagentoSetup."Variant System" of
          //-MAG2.02
          //MagentoSetup."Variant System"::"1": SetupVariantVariaX();
          //+MAG2.02
          MagentoSetup."Variant System"::Variety: SetupVariantVariety();
        end;

        HasVariants := Count > 1;
        //+MAG1.21
    end;

    local procedure SetupVariantVariaX()
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        TableNoVariaXDimCom: Integer;
        FieldNoDimNo: Integer;
        FieldNoDimValueCode: Integer;
        FieldNoDimValueDescription: Integer;
        FieldNoDisabled: Integer;
        FieldNoItemNo: Integer;
        VariantValueCode: Code[20];
        VariantValueDescription: Text[50];
    begin
        //-MAG2.02
        // //-MAG1.21
        // TableNoVariaXDimCom := 6014609;
        // IF NOT GenericSetupMgt.OpenRecRef(TableNoVariaXDimCom,RecRef) THEN
        //  EXIT;
        //
        // RecRef.CURRENTKEYINDEX(4);
        // FieldNoItemNo := 2;
        // GenericSetupMgt.SetFieldRefFilter(RecRef,FieldNoItemNo,ItemNo);
        // FieldNoDimNo := 3;
        // GenericSetupMgt.SetFieldRefFilter(RecRef,FieldNoDimNo,MagentoSetup."Variant Picture Dimension");
        // FieldNoDisabled := 5;
        // GenericSetupMgt.SetFieldRefFilter(RecRef,FieldNoDisabled,'0');
        //
        // IF NOT RecRef.FINDSET THEN
        //  EXIT;
        //
        // FieldNoDimValueCode := 4;
        // FieldNoDimValueDescription := 7;
        // WHILE RecRef.FINDFIRST DO BEGIN
        //  VariantValueCode := GenericSetupMgt.GetFieldRefValue(RecRef,FieldNoDimValueCode);
        //  VariantValueDescription := GenericSetupMgt.GetFieldRefValue(RecRef,FieldNoDimValueDescription);
        //  IF NOT GET(VariantValueCode,'') THEN BEGIN
        //    INIT;
        //    "Item No." := VariantValueCode;
        //    Description := VariantValueDescription;
        //    INSERT;
        //  END;
        //  GenericSetupMgt.SetFieldRefFilter(RecRef,FieldNoDimValueCode,'>' + VariantValueCode);
        // END;
        // //+MAG1.21
        //+MAG2.02
    end;

    local procedure SetupVariantVariety()
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldNoItemNo: Integer;
        FieldNoVariety: Integer;
        FieldNoVarietyTable: Integer;
        FieldNoVarietyValue: Integer;
        FieldNoBlocked: Integer;
        TableNoItemVariant: Integer;
        VariantValueDescription: Text[50];
        VariantValueCode: Code[20];
        VarietyTable: Code[20];
    begin
        //-MAG1.21
        TableNoItemVariant := 5401;
        if not GenericSetupMgt.OpenRecRef(TableNoItemVariant,RecRef) then
          exit;

        FieldNoItemNo := 2;
        GenericSetupMgt.SetFieldRefFilter(RecRef,FieldNoItemNo,ItemNo);

        FieldNoBlocked := 6059982;
        GenericSetupMgt.SetFieldRefFilter(RecRef,FieldNoBlocked,'0');

        if not SetItemVariantVarietyFieldNos(FieldNoVariety,FieldNoVarietyTable,FieldNoVarietyValue,VarietyTable) then
          exit;
        GenericSetupMgt.SetFieldRefFilter(RecRef,FieldNoVariety,MagentoSetup."Variant Picture Dimension");
        GenericSetupMgt.SetFieldRefFilter(RecRef,FieldNoVarietyTable,'' + VarietyTable +'' );

        //-MAG1.22
        //WHILE RecRef.FINDFIRST DO BEGIN
        if RecRef.FindSet then
          repeat
        //+MAG1.22
            VariantValueCode := GenericSetupMgt.GetFieldRefValue(RecRef,FieldNoVarietyValue);
            VariantValueDescription := GetVarietyValueDescription(MagentoSetup."Variant Picture Dimension",VarietyTable,VariantValueCode);
            if not Get(VariantValueCode,'') then begin
              Init;
              "Item No." := VariantValueCode;
              Description := VariantValueDescription;
              Insert;
            end;
        //-MAG1.22
        //  GenericSetupMgt.SetFieldRefFilter(RecRef,FieldNoVarietyValue,'>' + VariantValueCode);
        //END;
          until RecRef.Next = 0;
        //+MAG1.22
        //+MAG1.21
    end;

    local procedure "--- Aux"()
    begin
    end;

    procedure GetVarietyValueDescription(VarietyType: Code[10];VarietyTable: Code[20];VarietyValue: Code[20]) VarietyValueDescription: Text
    var
        RecRef: RecordRef;
        TableNoVarietyValue: Integer;
        FieldNoVarietyDescription: Integer;
        FieldNoVarietyTable: Integer;
        FieldNoVarietyType: Integer;
        FieldNoVarietyValue: Integer;
    begin
        //-MAG1.21
        if (VarietyType = '') or (VarietyTable = '') or (VarietyValue = '') then
          exit('');

        TableNoVarietyValue := 6059973;
        if not GenericSetupMgt.OpenRecRef(TableNoVarietyValue,RecRef) then
          exit('');

        FieldNoVarietyType := 1;
        GenericSetupMgt.SetFieldRefFilter(RecRef,FieldNoVarietyType,VarietyType);
        FieldNoVarietyTable := 2;
        GenericSetupMgt.SetFieldRefFilter(RecRef,FieldNoVarietyTable,VarietyTable);
        FieldNoVarietyValue := 3;
        GenericSetupMgt.SetFieldRefFilter(RecRef,FieldNoVarietyValue,VarietyValue);
        if not RecRef.FindFirst then
          exit('');

        FieldNoVarietyDescription := 20;
        exit(GenericSetupMgt.GetFieldRefValue(RecRef,FieldNoVarietyDescription));
        //+MAG1.21
    end;

    local procedure SetItemVariantVarietyFieldNos(var FieldNoVariety: Integer;var FieldNoVarietyTable: Integer;var FieldNoVarietyValue: Integer;var VarietyTable: Code[20]): Boolean
    var
        RecRef: RecordRef;
        FiledNoItemNo: Integer;
        FieldNoVariety1: Integer;
        FieldNoVariety2: Integer;
        FieldNoVariety3: Integer;
        FieldNoVariety4: Integer;
        TableNoItem: Integer;
    begin
        //-MAG1.21
        if (MagentoSetup."Variant System" <> MagentoSetup."Variant System"::Variety) or (MagentoSetup."Variant Picture Dimension" = '') then
          exit(false);

        TableNoItem := 27;
        if not GenericSetupMgt.OpenRecRef(TableNoItem,RecRef) then
          exit(false);

        FiledNoItemNo := 1;
        GenericSetupMgt.SetFieldRefFilter(RecRef,FiledNoItemNo,ItemNo);
        if not RecRef.FindFirst then
          exit(false);

        FieldNoVariety1 := 6059970;
        if GenericSetupMgt.GetFieldRefValue(RecRef,FieldNoVariety1) = MagentoSetup."Variant Picture Dimension" then begin
          FieldNoVariety := 6059970;
          FieldNoVarietyTable := 6059971;
          FieldNoVarietyValue := 6059972;
          VarietyTable := GenericSetupMgt.GetFieldRefValue(RecRef,FieldNoVarietyTable);
          exit(true);
        end;

        FieldNoVariety2 := 6059973;
        if GenericSetupMgt.GetFieldRefValue(RecRef,FieldNoVariety2) = MagentoSetup."Variant Picture Dimension" then begin
          FieldNoVariety := 6059973;
          FieldNoVarietyTable := 6059974;
          FieldNoVarietyValue := 6059975;
          VarietyTable := GenericSetupMgt.GetFieldRefValue(RecRef,FieldNoVarietyTable);
          exit(true);
        end;

        FieldNoVariety3 := 6059976;
        if GenericSetupMgt.GetFieldRefValue(RecRef,FieldNoVariety3) = MagentoSetup."Variant Picture Dimension" then begin
          FieldNoVariety := 6059976;
          FieldNoVarietyTable := 6059977;
          FieldNoVarietyValue := 6059978;
          VarietyTable := GenericSetupMgt.GetFieldRefValue(RecRef,FieldNoVarietyTable);
          exit(true);
        end;

        FieldNoVariety4 := 6059979;
        if GenericSetupMgt.GetFieldRefValue(RecRef,FieldNoVariety4) = MagentoSetup."Variant Picture Dimension" then begin
          FieldNoVariety := 6059979;
          FieldNoVarietyTable := 6059980;
          FieldNoVarietyValue := 6059981;
          VarietyTable := GenericSetupMgt.GetFieldRefValue(RecRef,FieldNoVarietyTable);
          exit(true);
        end;

        exit(false);
        //+MAG1.21
    end;
}

