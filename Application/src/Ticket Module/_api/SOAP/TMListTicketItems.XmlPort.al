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
                    tableelement(TmpItemVariant; "Item Variant")
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
                        textelement(TicketTypeDescription)
                        {
                            XmlName = 'ticket_type';
                            MinOccurs = Once;
                            MaxOccurs = Once;
                            textattribute(TicketTypeCode)
                            {
                                XmlName = 'id';
                                Occurrence = Optional;
                            }
                            textattribute(TicketTypeCategory)
                            {
                                XmlName = 'category';
                                Occurrence = Optional;
                            }
                        }
                        textelement(TicketDescription)
                        {
                            XmlName = 'ticket_description';
                            MinOccurs = Once;
                            MaxOccurs = Once;
                            textelement(ItemTitle)
                            {
                                XmlName = 'title';
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                                trigger OnBeforePassVariable()
                                begin
                                    ItemTitle := _TicketDescription.Title;
                                end;
                            }
                            textelement(ItemSubtitle)
                            {
                                XmlName = 'subtitle';
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                                trigger OnBeforePassVariable()
                                begin
                                    ItemSubtitle := _TicketDescription.Subtitle;
                                end;
                            }
                            textelement(ItemName)
                            {
                                XmlName = 'name';
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                                trigger OnBeforePassVariable()
                                begin
                                    ItemName := _TicketDescription.Name;
                                end;
                            }
                            textelement(ItemDescription)
                            {
                                XmlName = 'description';
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                                trigger OnBeforePassVariable()
                                begin
                                    ItemDescription := _TicketDescription.Description;
                                end;
                            }
                            textelement(ItemFullDescription)
                            {
                                XmlName = 'full_description';
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                                trigger OnBeforePassVariable()
                                begin
                                    ItemFullDescription := _TicketDescription.FullDescription;
                                end;
                            }
                        }
                        textelement("bill-of-material")
                        {
                            tableelement(_TicketBomResponse; "NPR TM Ticket Admission BOM")
                            {
                                AutoSave = false;
                                LinkFields = "Item No." = FIELD("Item No."), "Variant Code" = FIELD(Code);
                                LinkTable = TmpItemVariant;
                                LinkTableForceInsert = false;
                                XmlName = 'admission';
                                fieldattribute(code; _TicketBomResponse."Admission Code")
                                {
                                    XmlName = 'code';
                                    Description = 'This is the primary key of the admission (xmlport description).';
                                }
                                fieldattribute(default; _TicketBomResponse.Default)
                                {
                                    XmlName = 'default';
                                }
                                textelement(admission_type)
                                {
                                    XmlName = 'type';
                                    textattribute(admission_type_id)
                                    {
                                        XmlName = 'option_value';

                                        trigger OnBeforePassVariable()
                                        begin
                                            admission_type_id := Format(_TMAdmission.Type, 0, 9);
                                        end;
                                    }

                                    trigger OnBeforePassVariable()
                                    begin

                                        admission_type := Format(_TMAdmission.Type);
                                    end;
                                }
                                textelement(admission_is)
                                {
                                    XmlName = 'admission_is';
                                    textattribute(admission_is_id)
                                    {
                                        XmlName = 'option_value';
                                        Occurrence = Required;
                                        trigger OnBeforePassVariable()
                                        begin
                                            admission_is_id := Format(_TicketBomResponse."Admission Inclusion", 0, 9);
                                        end;
                                    }
                                    fieldattribute(recommended_price; _TicketBomResponse."Admission Unit Price")
                                    {
                                        XmlName = 'recommended_price';
                                        Occurrence = Optional;
                                    }

                                    textattribute(AdmissionItemNumber)
                                    {
                                        XmlName = 'item_number';
                                        Occurrence = Optional;
                                        Description = 'For optional admissions, setup is collected from this item rather than the master item.';
                                        trigger OnBeforePassVariable()
                                        begin
                                            AdmissionItemNumber := _TMAdmission."Additional Experience Item No.";
                                        end;
                                    }

                                    trigger OnBeforePassVariable()
                                    begin
                                        admission_is := Format(_TicketBomResponse."Admission Inclusion");
                                    end;
                                }
                                fieldelement(description; _TicketBomResponse.Description)
                                {
                                }
                                fieldelement(description2; _TicketBomResponse."Admission Description")
                                {
                                }
                                textelement(TicketAdmissionDescription)
                                {
                                    XmlName = 'admission_description';
                                    MinOccurs = Zero;
                                    MaxOccurs = Once;
                                    textelement(AdmissionTitle)
                                    {
                                        XmlName = 'title';
                                        MinOccurs = Zero;
                                        MaxOccurs = Once;
                                        trigger OnBeforePassVariable()
                                        begin
                                            AdmissionTitle := _TicketDescription.Title;
                                        end;
                                    }
                                    textelement(AdmissionSubtitle)
                                    {
                                        XmlName = 'subtitle';
                                        MinOccurs = Zero;
                                        MaxOccurs = Once;
                                        trigger OnBeforePassVariable()
                                        begin
                                            AdmissionSubtitle := _TicketDescription.Subtitle;
                                        end;
                                    }
                                    textelement(AdmissionName)
                                    {
                                        XmlName = 'name';
                                        MinOccurs = Zero;
                                        MaxOccurs = Once;
                                        trigger OnBeforePassVariable()
                                        begin
                                            AdmissionName := _TicketDescription.Name;
                                        end;
                                    }
                                    textelement(AdmissionDescription)
                                    {
                                        XmlName = 'description';
                                        MinOccurs = Zero;
                                        MaxOccurs = Once;
                                        trigger OnBeforePassVariable()
                                        begin
                                            AdmissionDescription := _TicketDescription.Description;
                                        end;
                                    }
                                    textelement(AdmissionFullDescription)
                                    {
                                        XmlName = 'full_description';
                                        MinOccurs = Zero;
                                        MaxOccurs = Once;
                                        trigger OnBeforePassVariable()
                                        begin
                                            AdmissionFullDescription := _TicketDescription.FullDescription;
                                        end;
                                    }

                                    trigger OnBeforePassVariable()
                                    begin
                                        if (_TMAdmission."Additional Experience Item No." = '') then
                                            currXMLport.Skip();
                                    end;
                                }
                                textelement(max_capacity)
                                {
                                    trigger OnBeforePassVariable()
                                    begin

                                        if (_TMAdmission."Capacity Control" = _TMAdmission."Capacity Control"::NONE) then
                                            _TMAdmission."Max Capacity Per Sch. Entry" := -1;

                                        max_capacity := Format(_TMAdmission."Max Capacity Per Sch. Entry", 0, 9);
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

                                            capacity_control_id := Format(_TMAdmission."Capacity Control", 0, 9);
                                        end;
                                    }

                                    trigger OnBeforePassVariable()
                                    begin

                                        capacity_control := Format(_TMAdmission."Capacity Control");
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

                                            default_schedule_id := Format(_TMAdmission."Default Schedule", 0, 9);
                                        end;
                                    }

                                    trigger OnBeforePassVariable()
                                    begin

                                        default_schedule := Format(_TMAdmission."Default Schedule");
                                    end;
                                }
                                textelement(ticket_schedule)
                                {
                                    XmlName = 'ticket_schedule_selection';
                                    textattribute(ticket_schedule_id)
                                    {
                                        XmlName = 'option_value';

                                        trigger OnBeforePassVariable()
                                        begin

                                            ticket_schedule_id := Format(_TicketBomResponse."Ticket Schedule Selection", 0, 9);
                                        end;
                                    }

                                    trigger OnBeforePassVariable()
                                    begin

                                        ticket_schedule := Format(_TicketBomResponse."Ticket Schedule Selection");
                                    end;
                                }
                                trigger OnAfterGetRecord()
                                begin
                                    _TMAdmission.Get(_TicketBomResponse."Admission Code");
                                    _TicketDescription.Get(_TicketBomResponse."Item No.", _TicketBomResponse."Variant Code", _TicketBomResponse."Admission Code");
                                end;
                            }
                        }

                        trigger OnAfterGetRecord()
                        var
                            TicketType: Record "NPR TM Ticket Type";
                        begin

                            _ItemResponse.Get(TmpItemVariant."Item No.");
                            item_number := _ItemResponse."No.";
                            description := _ItemResponse.Description;
                            recommended_price := Format(_ItemResponse."Unit Price", 0, 9);
                            includes_vat := Format(_ItemResponse."Price Includes VAT", 0, 9);

                            Clear(_ItemVariant);
                            variant_code := '';
                            variant_description := '';

                            if (_ItemVariant.Get(TmpItemVariant."Item No.", TmpItemVariant.Code)) then begin
                                variant_code := _ItemVariant.Code;
                                variant_description := _ItemVariant.Description;
                            end;

                            TicketTypeCode := _ItemResponse."NPR Ticket Type";
                            Clear(TicketTypeCategory);
                            Clear(TicketTypeDescription);
                            if (TicketType.Get(_ItemResponse."NPR Ticket Type")) then begin
                                TicketTypeDescription := TicketType.Description;
                                TicketTypeCategory := TicketType.Category;
                            end;

                            _ItemReference.SetFilter("Item No.", '=%1', TmpItemVariant."Item No.");
                            _ItemReference.SetFilter("Variant Code", '=%1', variant_code);
                            _ItemReference.SetFilter("Unit of Measure", '=%1|=%2|=%3', '', _ItemResponse."Sales Unit of Measure", _ItemResponse."Base Unit of Measure");
                            _ItemReference.SetFilter("Reference Type", '=%1', _ItemReference."Reference Type"::"Bar Code");

                            external_item_number := TmpItemVariant."Item No.";
                            if _ItemReference.FindFirst() then
                                external_item_number := _ItemReference."Reference No.";

                            _TicketDescription.Get(TmpItemVariant."Item No.", TmpItemVariant.Code, '')
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
        _GeneralLedgerSetup: Record "General Ledger Setup";
        _ItemReference: Record "Item Reference";
        _ItemVariant: Record "Item Variant";
        _TMAdmission: Record "NPR TM Admission";
        _ItemResponse: Record Item;
        _TicketDescription: Record "NPR TM TempTicketDescription";

#pragma warning disable AA0206 //The variable 'Inserted' is initialized but not used.
    internal procedure CreateResponse()
    var
        Item: Record Item;
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        Inserted: Boolean;
    begin

        _GeneralLedgerSetup.Get();
        currency_code := _GeneralLedgerSetup."LCY Code";

        Item.SetFilter("NPR Ticket Type", '<>%1', '');
        Item.SetFilter(Blocked, '=%1', false);
        if (not Item.FindSet()) then
            exit;
        repeat
            TmpItemVariant."Item No." := Item."No.";

            _ItemVariant.SetFilter("Item No.", '=%1', Item."No.");
            if (_ItemVariant.FindSet()) then begin
                repeat
                    TmpItemVariant.Code := _ItemVariant.Code;
                    if (TmpItemVariant.Insert()) then;
                until (_ItemVariant.Next() = 0);
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

        TmpItemVariant.Reset();
        if (TmpItemVariant.FindSet()) then begin
            repeat
                _TicketDescription.SetKeyAndDescription(TmpItemVariant."Item No.", TmpItemVariant.Code, '');
                _TicketDescription.AdmissionCode := '';
                Inserted := _TicketDescription.Insert();
            until (TmpItemVariant.Next() = 0);
        end;

        TicketBOM.Reset();
        if (TicketBOM.FindSet()) then begin
            repeat
                _TicketDescription.SetKeyAndDescription(TicketBOM."Item No.", TicketBOM."Variant Code", TicketBOM."Admission Code");

                if (Admission.Get(TicketBOM."Admission Code")) then
                    if (Admission."Additional Experience Item No." <> '') then
                        _TicketDescription.SetDescription(Admission."Additional Experience Item No.", '', TicketBOM."Admission Code");

                Inserted := _TicketDescription.Insert();

            until (TicketBOM.Next() = 0);
        end;

        Clear(_ItemVariant);
        _ItemVariant.Reset();
    end;
#pragma warning restore AA0206

    internal procedure GetResponse(var TmpItemVariantOut: Record "Item Variant" temporary)
    begin
        TmpItemVariantOut.Copy(TmpItemVariant, true);
    end;

    local procedure GetMagentoPath(RootNodeNo: Code[20]; ParentCode: Code[20]): Text
    var
        MagentoItemGroup: Record "NPR Magento Category";
        PathLbl: Label '%1%2/', Locked = true;
    begin

        MagentoItemGroup.SetFilter(Id, '=%1', ParentCode);
        if (not MagentoItemGroup.FindFirst()) then
            exit('');

        if (RootNodeNo = MagentoItemGroup."Parent Category Id") then
            exit('');

        exit(StrSubstNo(PathLbl,
          GetMagentoPath(RootNodeNo, MagentoItemGroup."Parent Category Id"),
          MagentoItemGroup."Seo Link"));
    end;
}

