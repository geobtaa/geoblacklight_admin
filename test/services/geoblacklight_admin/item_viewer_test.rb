# frozen_string_literal: true

require "test_helper"

module GeoblacklightAdmin
  class ItemViewerTest < ActiveSupport::TestCase
    setup do
      @document = documents(:ag) # Assuming you have a fixture or factory for documents
      @item_viewer = GeoblacklightAdmin::ItemViewer.new(@document.references)
      @references = {"http://schema.org/url" => "https://open-iowa.opendata.arcgis.com/datasets/35c8a641589c4e13b7aa11e37f3f00a1_0", "http://schema.org/downloadUrl" => [{"label" => "Original Shapefile", "url" => "https://open-iowa.opendata.arcgis.com/datasets/35c8a641589c4e13b7aa11e37f3f00a1_0.zip"}, {"label" => "Foo", "url" => "http://foo.com"}, {"label" => "Bar", "url" => "http://bar.com"}], "urn:x-esri:serviceType:ArcGIS#FeatureLayer" => "https://services2.arcgis.com/KhKjlwEBlPJd6v51/arcgis/rest/services/AgDistricts/FeatureServer/0"}
    end

    test "should initialize with references and keys" do
      assert_equal @references, @item_viewer.instance_variable_get(:@references)
      assert_equal [:url, :download, :feature_layer], @item_viewer.instance_variable_get(:@keys)
    end

    test "should return correct viewer protocol based on preference order" do
      # Testing viewer protocol based on preference
      assert_equal :feature_layer, @item_viewer.viewer_protocol

      # Modify preference and ensure the protocol changes accordingly
      @item_viewer.stub(:viewer_preference, [:iiif, :tilejson, :wms]) do
        assert_equal :map, @item_viewer.viewer_protocol
      end
    end

    test "should return correct viewer endpoint based on protocol" do
      # Testing viewer endpoint
      assert_equal "https://services2.arcgis.com/KhKjlwEBlPJd6v51/arcgis/rest/services/AgDistricts/FeatureServer/0", @item_viewer.viewer_endpoint

      # Modify preference to change the protocol and corresponding endpoint
      @item_viewer.stub(:viewer_preference, [:url, :download, :feature_layer]) do
        assert_equal "https://open-iowa.opendata.arcgis.com/datasets/35c8a641589c4e13b7aa11e37f3f00a1_0", @item_viewer.viewer_endpoint
      end
    end

    test "should correctly map reference URIs to keys" do
      assert_equal :wms, @item_viewer.reference_uri_2_key("http://www.opengis.net/def/serviceType/ogc/wms")
      assert_equal :iiif, @item_viewer.reference_uri_2_key("http://iiif.io/api/image")
      assert_nil @item_viewer.reference_uri_2_key("http://unknown/uri") # Simulating a missing mapping
    end

    test "should correctly map viewer protocol to endpoint" do
      assert_equal "https://services2.arcgis.com/KhKjlwEBlPJd6v51/arcgis/rest/services/AgDistricts/FeatureServer/0", @item_viewer.viewer_endpoint
    end
  end
end
