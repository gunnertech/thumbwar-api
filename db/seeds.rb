# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
challenger=User.create!(mobile:"1231231234", username:"challenger")
challengee=User.create!(mobile:"2342342345", username:"challengee")
follower=User.create!(mobile:"3453453456", username:"follower")
watcher=User.create!(mobile:"4564564567", username:"watcher")

tw1=Thumbwar.create!(challenger: challenger, challengee: challengee, body: "1")
tw2=Thumbwar.create!(challenger: challenger, challengee: challengee, body: "2")
tw3=Thumbwar.create!(challenger: challenger, challengee: challengee, body: "3")

challenger.followers << follower
tw1.watchers << watcher

tw1.update_attribute(:winner_id, challenger.id)