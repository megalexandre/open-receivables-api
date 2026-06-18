require 'rails_helper'

RSpec.describe 'GET /election', type: :request do
  let(:election_date) { Date.new(2026, 6, 15) }
  let(:date_param)    { election_date.strftime('%Y-%m-%d') }

  def get_election(date: date_param, member_type: nil)
    params = { date: date }
    params[:member_type] = member_type if member_type
    get '/election', params: params
    response.parsed_body
  end

  def member_ids(body)
    body['data'].map { |m| m['id'].to_i }
  end

  it 'lists a voter member with an active connection and no debt' do
    member = create(:member, voter: true)
    create(:connection, member: member)

    body = get_election

    expect(response).to have_http_status(:ok)
    expect(member_ids(body)).to eq([member.id])
    expect(body['total']).to eq(1)
  end

  it 'lists a member only once even with several active connections' do
    member = create(:member, voter: true)
    create(:connection, member: member)
    create(:connection, member: member)

    body = get_election

    expect(member_ids(body)).to eq([member.id])
    expect(body['total']).to eq(1)
  end

  it 'excludes members flagged as non-voters' do
    member = create(:member, voter: false)
    create(:connection, member: member)

    expect(member_ids(get_election)).not_to include(member.id)
  end

  it 'excludes voter members without any active connection' do
    member = create(:member, voter: true)

    expect(member_ids(get_election)).not_to include(member.id)
  end

  it 'excludes voter members whose only connection is inactive' do
    member = create(:member, voter: true)
    connection = create(:connection, member: member)
    connection.soft_delete!

    expect(member_ids(get_election)).not_to include(member.id)
  end

  context 'overdue invoices' do
    it 'excludes a member with an unpaid invoice overdue by more than 60 days' do
      member = create(:member, voter: true)
      connection = create(:connection, member: member)
      create(:invoice, connection: connection, due_date: election_date - 61.days, paid_at: nil)

      expect(member_ids(get_election)).not_to include(member.id)
    end

    it 're-includes the member once that invoice is paid' do
      member = create(:member, voter: true)
      connection = create(:connection, member: member)
      invoice = create(:invoice, connection: connection, due_date: election_date - 61.days, paid_at: nil)

      expect(member_ids(get_election)).not_to include(member.id)

      invoice.update!(paid_at: Time.current)

      expect(member_ids(get_election)).to include(member.id)
    end

    it 'still excludes a member whose overdue debt belongs to an inactive connection' do
      member = create(:member, voter: true)
      create(:connection, member: member) # ligação ativa (requisito 2)
      inactive = create(:connection, member: member)
      create(:invoice, connection: inactive, due_date: election_date - 61.days, paid_at: nil)
      inactive.soft_delete!

      expect(member_ids(get_election)).not_to include(member.id)
    end

    it 'includes a member whose unpaid invoice is exactly 60 days overdue (boundary)' do
      member = create(:member, voter: true)
      connection = create(:connection, member: member)
      create(:invoice, connection: connection, due_date: election_date - 60.days, paid_at: nil)

      expect(member_ids(get_election)).to include(member.id)
    end

    it 'changes eligibility according to the election date' do
      member = create(:member, voter: true)
      connection = create(:connection, member: member)
      create(:invoice, connection: connection, due_date: election_date - 30.days, paid_at: nil)

      # Na data da eleição: vencida há 30 dias → ainda elegível.
      expect(member_ids(get_election)).to include(member.id)

      # 40 dias depois: vencida há 70 dias → desqualificada.
      later = (election_date + 40.days).strftime('%Y-%m-%d')
      expect(member_ids(get_election(date: later))).not_to include(member.id)
    end
  end

  context 'filtering by member_type' do
    let(:founder) { create(:category, member_type: 'Sócio Fundador') }
    let(:effective) { create(:category, member_type: 'Sócio Efetivo') }

    it 'keeps only voters with an active connection of the requested member_type' do
      founder_member = create(:member, voter: true)
      create(:connection, member: founder_member, category: founder)

      effective_member = create(:member, voter: true)
      create(:connection, member: effective_member, category: effective)

      ids = member_ids(get_election(member_type: 'Sócio Fundador'))

      expect(ids).to include(founder_member.id)
      expect(ids).not_to include(effective_member.id)
    end

    it 'returns every eligible voter when no member_type is given' do
      founder_member = create(:member, voter: true)
      create(:connection, member: founder_member, category: founder)
      effective_member = create(:member, voter: true)
      create(:connection, member: effective_member, category: effective)

      ids = member_ids(get_election)

      expect(ids).to include(founder_member.id, effective_member.id)
    end
  end

  it 'returns member fields via Election::MemberSerializer' do
    member = create(:member, voter: true)
    create(:connection, member: member)

    body = get_election

    expect(body['data'].first).to include('id', 'name', 'document', 'member_number', 'voter', 'active')
  end
end
