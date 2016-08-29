from random import randint

from app.userprofile.models import UserProfile, UserGroup
from app.userprofile.util import generate_user

def create_hidden_group_for_course(course):
    group = UserGroup()
    group.name = "custom_group-%s-%s" % (course.name, randint(0,1000000)) 
    group.is_hidden = True
    group.save()
    return group
    
def generate_user_for_course(course, username_prefix=None):
    username_prefix = username_prefix or course.name
    group = create_hidden_group_for_course(course)
    user = generate_user(username_prefix)
    user.groups.add(group)
    course.groups.add(group)
    
def generate_users_for_course(course, prefix, amount):
    for i in range(0,amount):
        generate_user_for_course(course, prefix)
    