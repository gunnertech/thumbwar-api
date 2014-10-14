challenger=User.create!(mobile:"11231231234", username:"challenger")
challengee=User.create!(mobile:"12342342345", username:"challengee")
follower=User.create!(mobile:"13453453456", username:"follower")
watcher=User.create!(mobile:"14564564567", username:"watcher")
invited=User.create!(mobile:"15675675678", username:"invited", inviter: challenger)

tw1=Thumbwar.create!(challenger: challenger, challengee: challengee, body: "1")
tw2=Thumbwar.create!(challenger: challenger, challengee: challengee, body: "2")
tw3=Thumbwar.create!(challenger: challenger, challengee: challengee, body: "3")

challenger.followers << follower
tw1.watchers << watcher

tw1.update_attribute(:winner_id, challenger.id)