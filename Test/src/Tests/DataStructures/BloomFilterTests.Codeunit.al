codeunit 85257 "NPR Bloom Filter Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Initialize_WithZeroElements_ThrowsError()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
    begin
        // [SCENARIO] Bloom filter throws error for zero expected elements
        // [GIVEN] Zero expected elements
        // [WHEN] Initialize is called
        // [THEN] Error is thrown
        asserterror BloomFilter.Initialize(0);
        Assert.ExpectedError('ExpectedElements must be greater than 0. Value: 0. This is a programming bug.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Initialize_WithNegativeElements_ThrowsError()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
    begin
        // [SCENARIO] Bloom filter throws error for negative expected elements
        // [GIVEN] Negative expected elements
        // [WHEN] Initialize is called
        // [THEN] Error is thrown
        asserterror BloomFilter.Initialize(-5);
        Assert.ExpectedError('ExpectedElements must be greater than 0. Value: -5. This is a programming bug.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Add_WithoutInitialize_ThrowsError()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
    begin
        // [SCENARIO] Adding to uninitialized filter throws error
        // [GIVEN] Uninitialized bloom filter
        // [WHEN] Add is called
        // [THEN] Error is thrown
        asserterror BloomFilter.Add('test');
        Assert.ExpectedError('Bloom filter is not initialized. Call Initialize first. This is a programming bug.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MayContain_WithoutInitialize_ThrowsError()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
    begin
        // [SCENARIO] Checking uninitialized filter throws error
        // [GIVEN] Uninitialized bloom filter
        // [WHEN] MayContain is called
        // [THEN] Error is thrown
        asserterror BloomFilter.MayContain('test');
        Assert.ExpectedError('Bloom filter is not initialized. Call Initialize first. This is a programming bug.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MayContain_AddedKey_ReturnsTrue()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        TestKey: Text;
    begin
        // [SCENARIO] Added key is found in filter
        // [GIVEN] Initialized bloom filter
        BloomFilter.Initialize(100);
        TestKey := 'ITEM-12345';

        // [WHEN] Key is added and then checked
        BloomFilter.Add(TestKey);

        // [THEN] MayContain returns true
        Assert.IsTrue(BloomFilter.MayContain(TestKey), 'Added key should be found in filter');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MayContain_EmptyFilter_AlwaysReturnsFalse()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
    begin
        // [SCENARIO] Empty filter returns false for any key (no bits are set)
        // [GIVEN] Initialized but empty bloom filter (all bits are 0)
        BloomFilter.Initialize(100);

        // [WHEN] Checking for any key in an empty filter
        // [THEN] MayContain returns false because no bits are set
        // Note: False positives can only occur after keys have been added
        Assert.IsFalse(BloomFilter.MayContain('ANY-KEY'), 'Empty filter must return false for any key');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NoFalseNegatives_AllAddedKeysFound()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        AddedKeys: List of [Text];
        KeyValue: Text;
        i: Integer;
    begin
        // [SCENARIO] Bloom filter never has false negatives
        // [GIVEN] Bloom filter with 50 random keys added
        BloomFilter.Initialize(100);

        for i := 1 to 50 do begin
            KeyValue := Format(CreateGuid());
            AddedKeys.Add(KeyValue);
            BloomFilter.Add(KeyValue);
        end;

        // [WHEN] Checking for all added keys
        // [THEN] All added keys must be found (no false negatives)
        foreach KeyValue in AddedKeys do
            Assert.IsTrue(BloomFilter.MayContain(KeyValue), 'Bloom filter must never have false negatives');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FalsePositiveRate_IsReasonable()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        AddedKeys: List of [Text];
        KeyValue: Text;
        i: Integer;
        FalsePositives: Integer;
        TotalChecks: Integer;
        FalsePositiveRate: Decimal;
    begin
        // [SCENARIO] False positive rate is within reasonable bounds
        // [GIVEN] Bloom filter configured for 0.1% false positive rate with 100 elements
        BloomFilter.Initialize(100);

        // Add 100 unique keys
        for i := 1 to 100 do begin
            KeyValue := 'ADDED-' + Format(CreateGuid());
            AddedKeys.Add(KeyValue);
            BloomFilter.Add(KeyValue);
        end;

        // [WHEN] Checking 1000 keys that were never added
        TotalChecks := 1000;
        FalsePositives := 0;
        for i := 1 to TotalChecks do begin
            KeyValue := 'NOTADDED-' + Format(CreateGuid());
            if BloomFilter.MayContain(KeyValue) then
                FalsePositives += 1;
        end;

        // [THEN] False positive rate should be below 2% (allowing margin for randomness, configured for 0.1%)
        FalsePositiveRate := FalsePositives / TotalChecks;
        Assert.IsTrue(FalsePositiveRate < 0.02,
            StrSubstNo('False positive rate %1 is too high (expected < 2%%)', FalsePositiveRate));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SameKey_AlwaysFound()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        i: Integer;
    begin
        // [SCENARIO] Same key is always found after adding
        // [GIVEN] Bloom filter with a key added
        BloomFilter.Initialize(100);
        BloomFilter.Add('CONSISTENT-KEY');

        // [WHEN] Checking the same key multiple times
        // [THEN] It is always found
        for i := 1 to 100 do
            Assert.IsTrue(BloomFilter.MayContain('CONSISTENT-KEY'), 'Same key must always be found');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EmptyString_CanBeAddedAndFound()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
    begin
        // [SCENARIO] Empty string can be added and found
        // [GIVEN] Initialized bloom filter
        BloomFilter.Initialize(100);

        // [WHEN] Adding empty string
        BloomFilter.Add('');

        // [THEN] Empty string is found
        Assert.IsTrue(BloomFilter.MayContain(''), 'Empty string should be found after adding');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LongKey_CanBeAddedAndFound()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        LongKey: Text;
    begin
        // [SCENARIO] Long keys can be added and found
        // [GIVEN] Initialized bloom filter
        BloomFilter.Initialize(100);
        LongKey := PadStr('', 1000, 'X');

        // [WHEN] Adding long key
        BloomFilter.Add(LongKey);

        // [THEN] Long key is found
        Assert.IsTrue(BloomFilter.MayContain(LongKey), 'Long key should be found after adding');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SpecialCharacters_CanBeAddedAndFound()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        SpecialKey: Text;
    begin
        // [SCENARIO] Keys with special characters can be added and found
        // [GIVEN] Initialized bloom filter
        BloomFilter.Initialize(100);
        SpecialKey := 'Key with spaces, æøå, émojis: 🎉, and symbols: !@#$%^&*()';

        // [WHEN] Adding key with special characters
        BloomFilter.Add(SpecialKey);

        // [THEN] Key is found
        Assert.IsTrue(BloomFilter.MayContain(SpecialKey), 'Key with special characters should be found');
    end;

    // ============ Bit Packing Tests ============

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BitPacking_SetBit_OnlyAffectsTargetBit()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        Key1: Text;
        Key2: Text;
    begin
        // [SCENARIO] Setting one bit doesn't affect other bits
        // [GIVEN] Bloom filter with one key added
        BloomFilter.Initialize(1000);
        Key1 := 'UNIQUE-KEY-1';
        Key2 := 'UNIQUE-KEY-2';

        // [WHEN] Adding first key
        BloomFilter.Add(Key1);

        // [THEN] First key is found, second is not
        Assert.IsTrue(BloomFilter.MayContain(Key1), 'First key should be found');
        // Note: Second key might be found due to hash collision, but we test the inverse

        // [WHEN] Adding second key
        BloomFilter.Add(Key2);

        // [THEN] Both keys are found
        Assert.IsTrue(BloomFilter.MayContain(Key1), 'First key should still be found after adding second');
        Assert.IsTrue(BloomFilter.MayContain(Key2), 'Second key should be found');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BitPacking_MultipleBitsInSameByte()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        AddedKeys: List of [Text];
        KeyValue: Text;
        i: Integer;
    begin
        // [SCENARIO] Multiple bits can be set in the same byte without corruption
        // [GIVEN] Small bloom filter where keys likely share bytes
        BloomFilter.Initialize(10);

        // [WHEN] Adding multiple keys (will likely set multiple bits in same bytes)
        for i := 1 to 8 do begin
            KeyValue := 'BIT-TEST-' + Format(i);
            AddedKeys.Add(KeyValue);
            BloomFilter.Add(KeyValue);
        end;

        // [THEN] All keys are found (no bit corruption)
        foreach KeyValue in AddedKeys do
            Assert.IsTrue(BloomFilter.MayContain(KeyValue),
                'All keys should be found after setting multiple bits: ' + KeyValue);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BitPacking_AddSameKeyTwice_NoDuplication()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        TempBlob1: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        FilterSize1: Integer;
        FilterSize2: Integer;
        HashCount1: Integer;
        HashCount2: Integer;
        InStr1: InStream;
        InStr2: InStream;
        Byte1: Byte;
        Byte2: Byte;
        ByteCount: Integer;
        AllBytesMatch: Boolean;
    begin
        // [SCENARIO] Adding the same key twice doesn't change the filter
        // [GIVEN] Bloom filter with a key added
        BloomFilter.Initialize(100);
        BloomFilter.Add('DUPLICATE-TEST');
        BloomFilter.GetFilter(TempBlob1, FilterSize1, HashCount1);

        // [WHEN] Adding the same key again
        BloomFilter.Add('DUPLICATE-TEST');
        BloomFilter.GetFilter(TempBlob2, FilterSize2, HashCount2);

        // [THEN] Filter state should be identical
        Assert.AreEqual(FilterSize1, FilterSize2, 'Filter size should not change');
        Assert.AreEqual(TempBlob1.Length(), TempBlob2.Length(), 'Blob size should not change');

        TempBlob1.CreateInStream(InStr1);
        TempBlob2.CreateInStream(InStr2);
        AllBytesMatch := true;
        ByteCount := TempBlob1.Length();
        while ByteCount > 0 do begin
            InStr1.Read(Byte1, 1);
            InStr2.Read(Byte2, 1);
            if Byte1 <> Byte2 then
                AllBytesMatch := false;
            ByteCount -= 1;
        end;
        Assert.IsTrue(AllBytesMatch, 'All bytes should match after adding same key twice');
    end;

    // ============ GetFilter/SetFilter Serialization Tests ============

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSetFilter_RoundTrip_PreservesState()
    var
        BloomFilter1: Codeunit "NPR Bloom Filter";
        BloomFilter2: Codeunit "NPR Bloom Filter";
        TempBlob: Codeunit "Temp Blob";
        FilterSize: Integer;
        HashCount: Integer;
        AddedKeys: List of [Text];
        KeyValue: Text;
        i: Integer;
    begin
        // [SCENARIO] Filter state can be exported and imported without losing data
        // [GIVEN] Bloom filter with keys added
        BloomFilter1.Initialize(100);
        for i := 1 to 20 do begin
            KeyValue := 'PERSIST-' + Format(i);
            AddedKeys.Add(KeyValue);
            BloomFilter1.Add(KeyValue);
        end;

        // [WHEN] Exporting and importing to a new filter
        BloomFilter1.GetFilter(TempBlob, FilterSize, HashCount);
        BloomFilter2.SetFilter(TempBlob, FilterSize, HashCount);

        // [THEN] All keys are found in the restored filter
        foreach KeyValue in AddedKeys do
            Assert.IsTrue(BloomFilter2.MayContain(KeyValue),
                'Key should be found after round-trip: ' + KeyValue);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSetFilter_PreservesFilterSize()
    var
        BloomFilter1: Codeunit "NPR Bloom Filter";
        BloomFilter2: Codeunit "NPR Bloom Filter";
        TempBlob: Codeunit "Temp Blob";
        FilterSize1: Integer;
        FilterSize2: Integer;
        HashCount1: Integer;
        HashCount2: Integer;
    begin
        // [SCENARIO] Filter size is preserved through export/import
        // [GIVEN] Bloom filter initialized
        BloomFilter1.Initialize(500);
        BloomFilter1.Add('TEST');

        // [WHEN] Exporting and importing
        BloomFilter1.GetFilter(TempBlob, FilterSize1, HashCount1);
        BloomFilter2.SetFilter(TempBlob, FilterSize1, HashCount1);
        BloomFilter2.GetFilter(TempBlob, FilterSize2, HashCount2);

        // [THEN] Filter parameters are preserved
        Assert.AreEqual(FilterSize1, FilterSize2, 'Filter size should be preserved');
        Assert.AreEqual(HashCount1, HashCount2, 'Hash count should be preserved');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetFilter_AllowsAddingMoreKeys()
    var
        BloomFilter1: Codeunit "NPR Bloom Filter";
        BloomFilter2: Codeunit "NPR Bloom Filter";
        TempBlob: Codeunit "Temp Blob";
        FilterSize: Integer;
        HashCount: Integer;
    begin
        // [SCENARIO] After importing a filter, new keys can be added
        // [GIVEN] Bloom filter exported and imported
        BloomFilter1.Initialize(100);
        BloomFilter1.Add('ORIGINAL-KEY');
        BloomFilter1.GetFilter(TempBlob, FilterSize, HashCount);
        BloomFilter2.SetFilter(TempBlob, FilterSize, HashCount);

        // [WHEN] Adding new key to imported filter
        BloomFilter2.Add('NEW-KEY');

        // [THEN] Both original and new keys are found
        Assert.IsTrue(BloomFilter2.MayContain('ORIGINAL-KEY'), 'Original key should be found');
        Assert.IsTrue(BloomFilter2.MayContain('NEW-KEY'), 'New key should be found');
    end;

    // ============ Bit Manipulation Correctness Tests ============

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BitManipulation_AllBitPositionsWork()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        AddedKeys: List of [Text];
        KeyValue: Text;
        i: Integer;
    begin
        // [SCENARIO] Bits at all positions (0-7 within a byte) work correctly
        // [GIVEN] Bloom filter sized to have multiple bytes
        BloomFilter.Initialize(100);

        // [WHEN] Adding many keys to exercise different bit positions
        for i := 1 to 50 do begin
            KeyValue := Format(CreateGuid());
            AddedKeys.Add(KeyValue);
            BloomFilter.Add(KeyValue);
        end;

        // [THEN] All keys are found
        foreach KeyValue in AddedKeys do
            Assert.IsTrue(BloomFilter.MayContain(KeyValue), 'Key should be found: ' + KeyValue);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BitManipulation_HighVolumeTest()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        AddedKeys: List of [Text];
        KeyValue: Text;
        i: Integer;
    begin
        // [SCENARIO] Bloom filter handles high volume of keys correctly
        // [GIVEN] Bloom filter sized for 10000 elements
        BloomFilter.Initialize(10000);

        // [WHEN] Adding 5000 keys
        for i := 1 to 5000 do begin
            KeyValue := 'HIGH-VOL-' + Format(i) + '-' + Format(CreateGuid());
            AddedKeys.Add(KeyValue);
            BloomFilter.Add(KeyValue);
        end;

        // [THEN] All added keys are found (no false negatives)
        foreach KeyValue in AddedKeys do
            Assert.IsTrue(BloomFilter.MayContain(KeyValue), 'High volume key should be found');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BitManipulation_BoundaryBytes()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        TempBlob: Codeunit "Temp Blob";
        FilterSize: Integer;
        HashCount: Integer;
        InStr: InStream;
        FirstByte: Byte;
        LastByte: Byte;
        ByteSize: Integer;
        i: Integer;
    begin
        // [SCENARIO] First and last bytes of the filter work correctly
        // [GIVEN] Bloom filter with keys added
        BloomFilter.Initialize(100);

        for i := 1 to 20 do
            BloomFilter.Add('BOUNDARY-' + Format(i));

        // [WHEN] Reading the filter blob
        BloomFilter.GetFilter(TempBlob, FilterSize, HashCount);
        ByteSize := TempBlob.Length();
        TempBlob.CreateInStream(InStr);

        // Read first byte
        InStr.Read(FirstByte, 1);

        // Read remaining bytes to get the last one
        for i := 2 to ByteSize do
            InStr.Read(LastByte, 1);

        // [THEN] Bytes are valid (0-255 range is implicit, but we verify they can be read)
        Assert.IsTrue(ByteSize > 0, 'Filter should have bytes');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MemoryEfficiency_BitPackingReducesSize()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        TempBlob: Codeunit "Temp Blob";
        FilterSize: Integer;
        HashCount: Integer;
        ByteSize: Integer;
    begin
        // [SCENARIO] Bit packing reduces memory by factor of 8 compared to byte-per-bit
        // [GIVEN] Bloom filter for 1000 elements
        BloomFilter.Initialize(1000);

        // [WHEN] Getting the filter size
        BloomFilter.GetFilter(TempBlob, FilterSize, HashCount);
        ByteSize := TempBlob.Length();

        // [THEN] ByteSize should be approximately FilterSize/8 (bit packing)
        // Without bit packing, ByteSize would equal FilterSize
        Assert.IsTrue(ByteSize < FilterSize,
            StrSubstNo('ByteSize (%1) should be much smaller than FilterSize (%2) due to bit packing', ByteSize, FilterSize));
        Assert.AreEqual((FilterSize + 7) div 8, ByteSize,
            'ByteSize should be exactly ceil(FilterSize/8)');
    end;

    // ============ SetFilter Validation Tests ============

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetFilter_FilterSizeBelowMinimum_ThrowsError()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        TempBlob: Codeunit "Temp Blob";
    begin
        // [SCENARIO] SetFilter rejects FilterSize < 2 (would break hash math: mod 0 / mod -1 on first lookup)
        // [GIVEN] An empty temp blob
        // [WHEN] SetFilter is called with FilterSize 1
        // [THEN] Error is thrown on import, not deferred to first Add/MayContain
        asserterror BloomFilter.SetFilter(TempBlob, 1, 7);
        Assert.ExpectedError('FilterSize must be >= 2');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetFilter_FilterSizeZero_ThrowsError()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        TempBlob: Codeunit "Temp Blob";
    begin
        // [SCENARIO] SetFilter rejects FilterSize = 0
        // [GIVEN] An empty temp blob
        // [WHEN] SetFilter is called with FilterSize 0
        // [THEN] Error is thrown
        asserterror BloomFilter.SetFilter(TempBlob, 0, 7);
        Assert.ExpectedError('FilterSize must be >= 2');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetFilter_HashCountZero_ThrowsError()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        DummyByte: Byte;
        i: Integer;
    begin
        // [SCENARIO] SetFilter rejects HashCount < 1 (would make MayContain return true for every key, silently breaking the filter)
        // [GIVEN] A blob with the correct byte count for FilterSize = 64
        TempBlob.CreateOutStream(OutStr);
        DummyByte := 0;
        for i := 1 to 8 do
            OutStr.Write(DummyByte, 1);

        // [WHEN] SetFilter is called with HashCount = 0
        // [THEN] Error is thrown
        asserterror BloomFilter.SetFilter(TempBlob, 64, 0);
        Assert.ExpectedError('HashCount must be >= 1');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetFilter_HashCountNegative_ThrowsError()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        DummyByte: Byte;
        i: Integer;
    begin
        // [SCENARIO] SetFilter rejects negative HashCount
        // [GIVEN] A blob with the correct byte count for FilterSize = 64
        TempBlob.CreateOutStream(OutStr);
        DummyByte := 0;
        for i := 1 to 8 do
            OutStr.Write(DummyByte, 1);

        // [WHEN] SetFilter is called with HashCount = -1
        // [THEN] Error is thrown
        asserterror BloomFilter.SetFilter(TempBlob, 64, -1);
        Assert.ExpectedError('HashCount must be >= 1');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetFilter_BlobTooSmall_ThrowsError()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        DummyByte: Byte;
    begin
        // [SCENARIO] SetFilter rejects when blob byte count is smaller than FilterSize requires (would cause Get() out-of-bounds at lookup)
        // [GIVEN] A blob with only 1 byte while FilterSize = 64 demands 8 bytes
        TempBlob.CreateOutStream(OutStr);
        DummyByte := 0;
        OutStr.Write(DummyByte, 1);

        // [WHEN] SetFilter is called
        // [THEN] Error is thrown on import
        asserterror BloomFilter.SetFilter(TempBlob, 64, 7);
        Assert.ExpectedError('blob is corrupted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetFilter_BlobTooLarge_ThrowsError()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        DummyByte: Byte;
        i: Integer;
    begin
        // [SCENARIO] SetFilter rejects when blob has more bytes than FilterSize requires (signals schema drift)
        // [GIVEN] A blob with 16 bytes while FilterSize = 64 demands 8 bytes
        TempBlob.CreateOutStream(OutStr);
        DummyByte := 0;
        for i := 1 to 16 do
            OutStr.Write(DummyByte, 1);

        // [WHEN] SetFilter is called
        // [THEN] Error is thrown on import
        asserterror BloomFilter.SetFilter(TempBlob, 64, 7);
        Assert.ExpectedError('blob is corrupted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetFilter_EmptyBlob_ThrowsError()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        TempBlob: Codeunit "Temp Blob";
    begin
        // [SCENARIO] SetFilter rejects empty blob when FilterSize requires bytes (e.g. cleared cache row in the database)
        // [GIVEN] An empty temp blob and FilterSize = 64
        // [WHEN] SetFilter is called
        // [THEN] Error is thrown on import
        asserterror BloomFilter.SetFilter(TempBlob, 64, 7);
        Assert.ExpectedError('blob is corrupted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure HashCount_IsReasonable()
    var
        BloomFilter: Codeunit "NPR Bloom Filter";
        TempBlob: Codeunit "Temp Blob";
        FilterSize: Integer;
        HashCount: Integer;
    begin
        // [SCENARIO] Hash count is calculated optimally
        // [GIVEN] Bloom filter for 100 elements
        BloomFilter.Initialize(100);

        // [WHEN] Getting the filter parameters
        BloomFilter.GetFilter(TempBlob, FilterSize, HashCount);

        // [THEN] Hash count should be reasonable (typically 7-10 for 0.1% false positive rate)
        // k = (m/n) * ln(2) where m/n ≈ 14.4 for p=0.001
        // k ≈ 14.4 * 0.693 ≈ 10
        Assert.IsTrue(HashCount >= 5, 'Hash count should be at least 5');
        Assert.IsTrue(HashCount <= 15, 'Hash count should not exceed 15');
    end;
}