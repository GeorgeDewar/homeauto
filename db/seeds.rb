# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

heat_pump = Device.create(name: 'Heat Pump', definition: 'FujitsuAC')
sw1 = Device.create(name: 'Switch 1', definition: 'WattsClever', properties: {
    on: '62E65A', off: '62E652'
}.to_json)

Task.create(name: 'Warm Weekday Mornings', expression: '45 6 * * 1-5', device: heat_pump, message: {
    state: :on,
    temp: 22,
    mode: :heat
}.to_json)
