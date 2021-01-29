xmlport 6060112 "NPR TM List Ticket Items"
{

    Caption = 'List Ticket Items';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;

    schema
    {
        textelement(ticket_items)
        {
            textelement(response)
            {
                MaxOccurs = Once;
                textelement(items)
                {
                    MinOccurs = Zero;
                    tableelement(tmpitemvariant; "Item Variant")
                    {
                        MinOccurs = Zero;
                        XmlName = 'item';
                        UseTemporary = true;
                        textattribute(external_item_number)
                        {
                            XmlName = 'external_item_number';
                        }
                        textelement(item_number)
                        {
                            XmlName = 'item_number';
                            textattribute(variant_code)
                            {
                                XmlName = 'variant_code';
                            }
                        }
                        textelement(description)
                        {
                            XmlName = 'description';
                        }
                        textelement(variant_description)
                        {
                            XmlName = 'variant_description';
                        }
                        textelement(recommended_price)
                        {
                            XmlName = 'recommended_price';
                            textattribute(currency_code)
                            {
                                XmlName = 'currency_code';
                            }
                            textattribute(includes_vat)
                            {
                                XmlName = 'includes_vat';
                            }
                        }
                        textelement("bill-of-material")
                        {
                            tableelement(ticketbomresponse; "NPR TM Ticket Admission BOM")
                            {
                                AutoSave = false;
                                LinkFields = "Item No." = FIELD("Item No."), "Variant Code" = FIELD(Code);
                                LinkTable = TmpItemVariant;
                                LinkTableForceInsert = false;
                                XmlName = 'admission';
                                fieldattribute(code; TicketBomResponse."Admission Code")
                                {
                                }
                                fieldattribute(default; TicketBomResponse.Default)
                                {
                                }
                                textelement(admission_type)
                                {
                                    XmlName = 'type';
                                    textattribute(admission_type_id)
                                    {
                                        XmlName = 'option_value';

                                        trigger OnBeforePassVariable()
                                        begin

                                            admission_type_id := Format(TMAdmission.Type, 0, 9);
                                        end;
                                    }

                                    trigger OnBeforePassVariable()
                                    begin

                                        admission_type := Format(TMAdmission.Type);
                                    end;
                                }
                                textelement(admission_is)
                                {
                                    XmlName = 'admission_is';
                                    textattribute(admission_is_id)
                                    {
                                        XmlName = 'option_value';

                                        trigger OnBeforePassVariable()
                                        begin

                                            admission_is_id := Format(TicketBomResponse."Admission Inclusion", 0, 9);
                                        end;
                                    }
                                    fieldattribute(recommended_price; TicketBomResponse."Admission Unit Price")
                                    {
                                    }

                                    trigger OnBeforePassVariable()
                                    begin

                                        admission_is := Format(TicketBomResponse."Admission Inclusion");
                                    end;
                                }
                                fieldelement(description; TicketBomResponse.Description)
                                {
                                }
                                fieldelement(description2; TicketBomResponse."Admission Description")
                                {
                                }
                                textelement(max_capacity)
                                {

                                    trigger OnBeforePassVariable()
                                    begin

                                        if (TMAdmission."Capacity Control" = TMAdmission."Capacity Control"::NONE) then
                                            TMAdmission."Max Capacity Per Sch. Entry" := -1;

                                        max_capacity := Format(TMAdmission."Max Capacity Per Sch. Entry", 0, 9);
                                    end;
                                }
                                textelement(capacity_control)
                                {
                                    XmlName = 'capacity_control';
                                    textattribute(capacity_control_id)
                                    {
                                        XmlName = 'option_value';

                                        trigger OnBeforePassVariable()
                                        begin

                                            capacity_control_id := Format(TMAdmission."Capacity Control", 0, 9);
                                        end;
                                    }

                                    trigger OnBeforePassVariable()
                                    begin

                                        capacity_control := Format(TMAdmission."Capacity Control");
                                    end;
                                }
                                textelement(default_schedule)
                                {
                                    XmlName = 'default_schedule_selection';
                                    textattribute(default_schedule_id)
                                    {
                                        XmlName = 'option_value';

                                        trigger OnBeforePassVariable()
                                        begin

                                            default_schedule_id := Format(TMAdmission."Default Schedule", 0, 9);
                                        end;
                                    }

                                    trigger OnBeforePassVariable()
                                    begin

                                        default_schedule := Format(TMAdmission."Default Schedule");
                                    end;
                                }

                                trigger OnAfterGetRecord()
                                begin

                                    TMAdmission.Get(TicketBomResponse."Admission Code");
                                end;
                            }
                        }

                        trigger OnAfterGetRecord()
                        begin

                            ItemResponse.Get(TmpItemVariant."Item No.");

                            item_number := ItemResponse."No.";
                            description := ItemResponse.Description;
                            recommended_price := Format(ItemResponse."Unit Price", 0, 9);
                            includes_vat := Format(ItemResponse."Price Includes VAT", 0, 9);

                            Clear(ItemVariant);
                            variant_code := '';
                            variant_description := '';

                            if (ItemVariant.Get(TmpItemVariant."Item No.", TmpItemVariant.Code)) then begin
                                variant_code := ItemVariant.Code;
                                variant_description := ItemVariant.Description;
                            end;

                            ItemCrossReference.SetFilter("Item No.", '=%1', TmpItemVariant."Item No.");
                            ItemCrossReference.SetFilter("Variant Code", '=%1', variant_code);
                            ItemCrossReference.SetFilter("Unit of Measure", '=%1|=%2|=%3', '', ItemResponse."Sales Unit of Measure", ItemResponse."Base Unit of Measure");
                            ItemCrossReference.SetFilter("Cross-Reference Type", '=%1', ItemCrossReference."Cross-Reference Type"::"Bar Code");

                            external_item_number := TmpItemVariant."Item No.";
                            if (ItemCrossReference.FindFirst()) then
                                external_item_number := ItemCrossReference."Cross-Reference No.";
                        end;
                    }
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ItemCrossReference: Record "Item Cross Reference";
        ItemVariant: Record "Item Variant";
        TMAdmission: Record "NPR TM Admission";
        ItemResponse: Record Item;

    procedure CreateResponse()
    var
        Item: Record Item;
        TicketBOM: Record "NPR TM Ticket Admission BOM";
    begin

        GeneralLedgerSetup.Get();
        currency_code := GeneralLedgerSetup."LCY Code";

        Item.SetFilter("NPR Ticket Type", '<>%1', '');
        Item.SetFilter(Blocked, '=%1', false);
        if (not Item.FindSet()) then
            exit;

        repeat
            TmpItemVariant."Item No." := Item."No.";

            ItemVariant.SetFilter("Item No.", '=%1', Item."No.");
            if (ItemVariant.FindSet()) then begin
                repeat
                    TmpItemVariant.Code := ItemVariant.Code;
                    if (TmpItemVariant.Insert()) then;
                until (ItemVariant.Next() = 0);
            end else begin
                TmpItemVariant.Code := '';
                if (TmpItemVariant.Insert()) then;
            end;

        until (Item.Next() = 0);

        TmpItemVariant.Reset();
        if (TmpItemVariant.FindSet()) then begin
            repeat
                TicketBOM.SetFilter("Item No.", '=%1', TmpItemVariant."Item No.");
                TicketBOM.SetFilter("Variant Code", '=%1', TmpItemVariant.Code);
                if (TicketBOM.IsEmpty()) then
                    TmpItemVariant.Delete();

            until (TmpItemVariant.Next() = 0);
        end;

        Clear(ItemVariant);
        ItemVariant.Reset();
    end;

    procedure GetResponse(var TmpItemVariantOut: Record "Item Variant" temporary)
    begin
        TmpItemVariantOut.Copy(TmpItemVariant, true);
    end;

    local procedure GetFirstMagentoURL(ItemNo: Code[20]): Text
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoItemGroupLink: Record "NPR Magento Category Link";
        Item: Record Item;
    begin

        MagentoItemGroupLink.SetFilter("Item No.", '=%1', ItemNo);
        if (not MagentoItemGroupLink.FindFirst()) then
            exit('');

        if (not MagentoSetup.Get()) then
            exit('');

        if (MagentoSetup."Magento Url" = '') then
            exit('');

        Item.Get(ItemNo);

        exit(StrSubstNo('%1%2%3',
          MagentoSetup."Magento Url",
          GetMagentoPath(MagentoItemGroupLink."Root No.", MagentoItemGroupLink."Category Id"),
          Item."NPR Seo Link"));
    end;

    local procedure GetMagentoPath(RootNodeNo: Code[20]; ParentCode: Code[20]): Text
    var
        MagentoItemGroup: Record "NPR Magento Category";
    begin

        MagentoItemGroup.SetFilter(Id, '=%1', ParentCode);
        if (not MagentoItemGroup.FindFirst()) then
            exit('');

        if (RootNodeNo = MagentoItemGroup."Parent Category Id") then
            exit('');

        exit(StrSubstNo('%1%2/',
          GetMagentoPath(RootNodeNo, MagentoItemGroup."Parent Category Id"),
          MagentoItemGroup."Seo Link"));
    end;
}

