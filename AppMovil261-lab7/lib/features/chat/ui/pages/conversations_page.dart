import 'package:appmovil261/features/chat/ui/bloc/users_bloc.dart';
import 'package:appmovil261/features/chat/ui/pages/chat_page.dart';
import 'package:appmovil261/features/profile/domain/model/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;

    return BlocProvider(
      create: (_) => UsersBloc()..add(LoadUsersEvent()),
      child: BlocListener<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is NavigateToChatState) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  conversationId: state.conversationId,
                  otherUserName: state.otherUserName,
                ),
              ),
            );
          }
        },
        child: BlocBuilder<UsersBloc, UsersState>(
          buildWhen: (previous, current) => current is! NavigateToChatState,
          builder: (context, state) {
            if (state is UsersLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is UsersErrorState) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is UsersLoadedState) {
              if (state.users.isEmpty) {
                return const Center(child: Text('No hay otros usuarios aún'));
              }
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return _UserTile(user: user, currentUserId: currentUserId);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final Profile user;
  final String currentUserId;

  const _UserTile({required this.user, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return ListTile(
      leading: CircleAvatar(child: Text(initial)),
      title: Text(user.name),
      subtitle: Text(user.email),
      onTap: () {
        context.read<UsersBloc>().add(SelectUserEvent(currentUserId, user));
      },
    );
  }
}
