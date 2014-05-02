require 'spec_helper'

module Union::Trello
  describe CachedCardTags do
    describe '.tags' do
      let(:projects_card_tags) { { project_1: { project_id: 1 }, oddly_similar_name: { project_id: 200 } }.with_indifferent_access }
      let(:servers_card_tags) { { server_1: { server_id: 100 }, oddly_similar_name: { server_id: 2 } }.with_indifferent_access }

      before do
        Project.stub card_tags: projects_card_tags
        Server.stub card_tags: servers_card_tags
      end

      context "when Rails cache doesn't contain contain cached card tags" do
        it 'returns merged projects and servers cached tags' do
          Rails.cache.delete 'cached_card_tags'
          merged_card_tags = projects_card_tags.deep_merge(servers_card_tags)
          expect(described_class.tags).to eq(merged_card_tags)
        end
      end

      context 'when Rails cache contains cached card tags' do
        it "doesn't call Projects.card_tags or Server.card_tags" do
          Rails.cache.write('cached_card_tags', {}.with_indifferent_access)
          Project.should_not_receive(:card_tags)
          Server.should_not_receive(:card_tags)
          described_class.tags
        end
      end
    end
  end
end
