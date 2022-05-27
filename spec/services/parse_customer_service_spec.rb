require 'rspec'
require_relative '../../app/services/parse_customer_service'

describe ParseCustomerService do
  describe '#execute' do
    it 'parses pipes into customers' do
      customers = ParseCustomerService.execute(file_name: 'data/pipes.txt', delimiter: '|', sort_by: 'full_name')

      expect(customers).to contain_exactly(
        match(
          first_name: 'Ansel',
          last_name: 'Adams',
          full_name: 'Ansel Adams',
          email: 'a@adams.com',
          vehicle_type: 'motorboat',
          vehicle_name: 'Rushing Water',
          vehicle_length: '24’',
        ),
        match(
          first_name: 'Isatou',
          last_name: 'Ceesay',
          full_name: 'Isatou Ceesay',
          email: 'isatou@recycle.com',
          vehicle_type: 'campervan',
          vehicle_name: 'Plastic To Purses',
          vehicle_length: '20’',
        ),
        match(
          first_name: 'Naomi',
          last_name: 'Uemura',
          full_name: 'Naomi Uemura',
          email: 'n.uemura@gmail.com',
          vehicle_type: 'bicycle',
          vehicle_name: 'Glacier Glider',
          vehicle_length: '5 feet',
        ),
        match(
          first_name: 'Steve',
          last_name: 'Irwin',
          full_name: 'Steve Irwin',
          email: 'steve@crocodiles.com',
          vehicle_type: 'RV',
          vehicle_name: 'G’Day For Adventure',
          vehicle_length: "32 ft",
        ),
      )
    end

    it 'sorts pipes by full_name' do
      customers = ParseCustomerService.execute(file_name: 'data/pipes.txt', delimiter: '|', sort_by: 'full_name')

      customer_full_names = customers.map { |customer| customer[:full_name] }
      expect(customer_full_names).to eq(['Ansel Adams', 'Isatou Ceesay', 'Naomi Uemura', 'Steve Irwin'])
    end

    it 'sorts pipes by vehicle_type (ignoring case)' do
      customers = ParseCustomerService.execute(file_name: 'data/pipes.txt', delimiter: '|', sort_by: 'vehicle_type')

      customer_vehicle_types = customers.map { |customer| customer[:vehicle_type] }
      expect(customer_vehicle_types).to eq(['bicycle', 'campervan', 'motorboat', 'RV'])
    end

    it 'parses commas into customers' do
      customers = ParseCustomerService.execute(file_name: 'data/commas.txt', delimiter: ',', sort_by: 'full_name')

      expect(customers).to contain_exactly(
        match(
          first_name: 'Greta',
          last_name: 'Thunberg',
          full_name: 'Greta Thunberg',
          email: 'greta@future.com',
          vehicle_type: 'sailboat',
          vehicle_name: 'Fridays For Future',
          vehicle_length: '32’',
        ),
        match(
          first_name: 'Jimmy',
          last_name: 'Buffet',
          full_name: 'Jimmy Buffet',
          email: 'jb@sailor.com',
          vehicle_type: 'sailboat',
          vehicle_name: 'Margaritaville',
          vehicle_length: '40 ft',
        ),
        match(
          first_name: 'Mandip',
          last_name: 'Singh Soin',
          full_name: 'Mandip Singh Soin',
          email: 'mandip@ecotourism.net',
          vehicle_type: 'motorboat',
          vehicle_name: 'Frozen Trekker',
          vehicle_length: '32’',
        ),
        match(
          first_name: 'Xiuhtezcatl',
          last_name: 'Martinez',
          full_name: 'Xiuhtezcatl Martinez',
          email: 'martinez@earthguardian.org',
          vehicle_type: 'campervan',
          vehicle_name: 'Earth Guardian',
          vehicle_length: '28 feet',
        ),
      )
    end

    it 'sorts commas by full_name' do
      customers = ParseCustomerService.execute(file_name: 'data/commas.txt', delimiter: ',', sort_by: 'full_name')

      customer_full_names = customers.map { |customer| customer[:full_name] }
      expect(customer_full_names).to eq(['Greta Thunberg', 'Jimmy Buffet', 'Mandip Singh Soin', 'Xiuhtezcatl Martinez'])
    end

    it 'sorts commas by vehicle_type' do
      customers = ParseCustomerService.execute(file_name: 'data/commas.txt', delimiter: ',', sort_by: 'vehicle_type')

      customer_vehicle_types = customers.map { |customer| customer[:vehicle_type] }
      expect(customer_vehicle_types).to eq(['campervan', 'motorboat', 'sailboat', 'sailboat'])
    end

    it 'raises an InvalidSortByError' do
      expect { ParseCustomerService.execute(file_name: 'data/commas.txt', delimiter: ',', sort_by: 'yolo_baggins') }
        .to raise_error(ParseCustomerService::InvalidSortByError)
    end

    it 'raises an InvalidDelimiterError' do
      expect { ParseCustomerService.execute(file_name: 'data/commas.txt', delimiter: ':', sort_by: 'full_name') }
        .to raise_error(ParseCustomerService::InvalidDelimiterError)
    end

    it 'raises an UnexpectedLineError' do
      expect { ParseCustomerService.execute(file_name: 'data/semicolons.txt', delimiter: ',', sort_by: 'full_name') }
        .to raise_error(ParseCustomerService::UnexpectedLineError)
    end

    it 'raises an Errno::ENOENT if file not found' do
      expect { ParseCustomerService.execute(file_name: 'data/yolo.txt', delimiter: ',', sort_by: 'full_name') }
        .to raise_error(Errno::ENOENT)
    end
  end
end