module ActivityPubSpecHelpers
  def message_with_history(account)
    message = create(:message, account: account)
    message.transact
    message.reload
    message.update(body: Faker::Lorem.sentence)
    message.transact
    message.reload
  end

  def real_federated_account
    public_key = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw60ENgVdXc7GXidTB7E4\nBGFL5eHKe8A9Og7l8rqMH3rli9Ibu9XLXnUZZl4VJoeEQGODQokmCq+dXrAA0ra1\nVj44s0UCFCBvU33RYDoZ/rCL9tmEVJz9/IRfkUqk1ru3evQu+jLQ52bnYDCTB/by\nErxXgsGa8dDHTxllttxFLdUV+a3D473VMiGqIG3ldPkwvXdccg2TY02BjiM9sbiq\nZSnBE+teNMDE9SD4ls0G0M3VpA804rTzDQnOH3Dm8gfUZcQq7oiIXkNITvcdpWYe\nJQSnqMdvx1yVhkuC+bOLrBkGXC8I6Q36JL1cXoE8KqiOBm8gBlSrNU7Fc8wWuyOE\nxQIDAQAB\n-----END PUBLIC KEY-----\n"
    private_key = "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAw60ENgVdXc7GXidTB7E4BGFL5eHKe8A9Og7l8rqMH3rli9Ib\nu9XLXnUZZl4VJoeEQGODQokmCq+dXrAA0ra1Vj44s0UCFCBvU33RYDoZ/rCL9tmE\nVJz9/IRfkUqk1ru3evQu+jLQ52bnYDCTB/byErxXgsGa8dDHTxllttxFLdUV+a3D\n473VMiGqIG3ldPkwvXdccg2TY02BjiM9sbiqZSnBE+teNMDE9SD4ls0G0M3VpA80\n4rTzDQnOH3Dm8gfUZcQq7oiIXkNITvcdpWYeJQSnqMdvx1yVhkuC+bOLrBkGXC8I\n6Q36JL1cXoE8KqiOBm8gBlSrNU7Fc8wWuyOExQIDAQABAoIBAQCDYlSFgSyjpAcF\niRny/EdEiZ/Qhr7SQM3bgc1cIW2cZYRjUXxVrsOSdMXNOjaxXCSspySnNDdazXe4\n8CxdT1iKw9SGajtvECgvwzcmiVyS6i/QW1TDC3ZuauNQRvJPTFNyNyqjzCMAfNO2\nfmb63hDEC7omjaBf5XMt5TuqgFPi5Rf2M5gZegPN64iKtf9miJkK1FZW15+mZi+K\neiWN3ZKb7oaOGPqwvP58yabXSSelUlLu2PikBhjPBpQVmgUw3EbjGtzZPRXHXeOM\n2WWWK+whOrgow2AI9uDao7Y84EXRxABM0o5/2DeMeuuBZJVfuSDfio0NXjTW7wTM\nu1uCw8oxAoGBAOOWzltTKKjsfRlCii+lNu1GKtRoexJ/rIRzrUOTZ3njJ0U9J6go\nsrwx3XjjfQot1XGWJRL4T87QecQCZuvmLTljWqfeDu6qkJ7j0M2te4sS/0NiJ27N\n7TurIJR7FucZIjP/x+TMf+cLqyVxzH8ue/SE6mgLpf+e1rk+fTO/I2UTAoGBANwa\nVz0cwKiDo7yyDmBP7vIRmS2Q5xnVy6Hm6BiOarD55K7SOrxX6znUgaIumaUCIrf2\nG/sqDCxUBeMWavrGCJb2xESDKiMQ1C2Ch/cH2Q/FWeEURSaT42oLK/NO5HyhPeDO\npR1ZXlmgic1j/ZsOAhqhcvWxgCO0O52O1EuwlaHHAoGBAMmhe+UxAZ7XFeXhK6gW\niVkhhyR0BEVZU7BtA54Q4+X6t3oCOjYjCGbvDrXhZZA1Fxrw2Ju73ojt7lMXhbON\nU5e6TEDY3QXZmxMJ5p2yCvgltn0uYp0qV/k7HTwu6RWJEOJcw+4St2Ys0k30SiaL\nOkphz4Kqf0C+qqGnmSjVODh9AoGAXnrgH9eLy8pWKtWz3hvx0e9D9Y9R5IElnCXm\nU0QvADEEvRZ5KAgFbRmPW/Ls+Svlg1odwL7X4t9ed5BT87m2Tjc3IMG9ALhkm/SA\nMMYpot9wKXHuDRVGdWq+Pv8KjYUZbrrFnceS/J4xCP13C2wD8zKCinzbKHhhbsy0\nzJjMYlkCgYBTmnelDrgb65Bbe/C9MUJDGhLa/iLOG+rhyzhdkqdhP1/MnA8sYDn9\nLvGBDjG3QMC69/hELw9oidoSxZHFWqecFoqMgHigAMjcmlxlws+/+MWmbSlmZ/Qf\nL9ucn0cvOypXCbnIVFYFWYED84Z6MYzbcSco+BGqL+sz7qVXifxRpw==\n-----END RSA PRIVATE KEY-----\n"
    address = "0x69259eef222c232a3cb3599a3556cc371f014121"
    account = create(:transacted_account, address: address)
    federated_account = account.reload.federated_account
    federated_account.update(private_key: private_key, public_key: public_key, local_account: account)
    federated_account
  end
end